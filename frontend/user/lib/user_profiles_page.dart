import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'liked_user_manager.dart';
import 'services/api_config.dart';
import 'user_session.dart';

class PublicUserProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoBase64;

  PublicUserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoBase64,
  });

  factory PublicUserProfile.fromJson(Map<String, dynamic> json) {
    return PublicUserProfile(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'User').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      photoBase64: json['photo']?.toString(),
    );
  }
}

class UserProfilesPage extends StatefulWidget {
  const UserProfilesPage({super.key});

  @override
  State<UserProfilesPage> createState() => _UserProfilesPageState();
}

class _UserProfilesPageState extends State<UserProfilesPage> {
  static const Color primaryGreen = Color(0xFF4E7F6D);

  bool isLoading = true;
  String? errorMessage;
  List<PublicUserProfile> users = [];
  int currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.86);

    final currentUserId = UserSession.instance.userId;
    if (currentUserId != null) {
      LikedUserManager.instance.switchUser(currentUserId);
    } else {
      LikedUserManager.instance.initialize();
    }

    _loadUsers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/public-users'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : (decoded['data'] ?? []) as List;

        final currentUserId = UserSession.instance.userId;
        final loaded = list
            .whereType<Map<String, dynamic>>()
            .map(PublicUserProfile.fromJson)
            .where((u) => u.id.isNotEmpty)
            .where((u) => currentUserId == null ? true : u.id != currentUserId)
            .toList();

        if (!mounted) return;
        setState(() {
          users = loaded;
          currentIndex = 0;
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Server error ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Connection error: $e';
      });
    }
  }

  ImageProvider _avatarProvider(String? photoBase64) {
    if (photoBase64 != null && photoBase64.trim().isNotEmpty) {
      try {
        final raw = photoBase64.contains(',')
            ? photoBase64.split(',').last
            : photoBase64;
        return MemoryImage(base64Decode(raw));
      } catch (_) {}
    }
    return const AssetImage('assets/images/person.jpeg');
  }

  Future<void> _toggleLike(PublicUserProfile user) async {
    final nowLiked = await LikedUserManager.instance.toggle(user.id);
    if (!mounted) return;

    if (nowLiked) {
      // Fire-and-forget: store notification for the liked user (shows in their Notifications page)
      _sendLikeNotification(user.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowLiked ? 'Liked' : 'Unliked'),
        backgroundColor: primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );

    setState(() {});
  }

  Future<void> _sendLikeNotification(String targetUserId) async {
    try {
      final token = UserSession.instance.token;
      if (token == null || token.trim().isEmpty) return;

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/notifications/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'targetUserId': targetUserId}),
      );
    } catch (_) {
      // Ignore: notifications are a best-effort enhancement
    }
  }

  void _continueToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _continueToHome();
      },
      child: Scaffold(
        backgroundColor: primaryGreen,
        appBar: AppBar(
          backgroundColor: primaryGreen,
          elevation: 0,
          title: const Text(
            'Users',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryGreen),
                      )
                    : (errorMessage != null)
                        ? Center(
                            child: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : users.isEmpty
                            ? const Center(
                                child: Text(
                                  'No users available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Align(
                                alignment: Alignment.topCenter,
                                child: _carousel(),
                              ),
              ),
              if (!isLoading && errorMessage == null && users.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${currentIndex + 1} / ${users.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continueToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/left-arrow.png',
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carousel() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: PageView.builder(
          controller: _pageController,
          itemCount: users.length,
          onPageChanged: (i) {
            setState(() => currentIndex = i);
          },
          itemBuilder: (context, i) {
            final user = users[i];
            final liked = LikedUserManager.instance.isLiked(user.id);

            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double scale = 1.0;
                if (_pageController.hasClients &&
                    _pageController.position.haveDimensions) {
                  final page = _pageController.page ??
                      _pageController.initialPage.toDouble();
                  final diff = (page - i).abs();
                  scale = (1 - (diff * 0.08)).clamp(0.92, 1.0);
                }
                return Center(
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: _avatarProvider(user.photoBase64),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.00),
                                Colors.black.withValues(alpha: 0.55),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            '${i + 1}/${users.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if ((user.phone ?? '').trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/call.png',
                                      width: 16,
                                      height: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        user.phone!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if ((user.email ?? '').trim().isNotEmpty)
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/msg.png',
                                    width: 16,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      user.email!.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => _toggleLike(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryGreen,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/star.png',
                                      width: 20,
                                      height: 20,
                                      color: liked ? primaryGreen : Colors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      liked ? 'Liked' : 'Like',
                                      style: TextStyle(
                                        color: liked ? primaryGreen : Colors.black87,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
