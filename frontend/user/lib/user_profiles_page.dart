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
  int index = 0;

  @override
  void initState() {
    super.initState();

    final currentUserId = UserSession.instance.userId;
    if (currentUserId != null) {
      LikedUserManager.instance.switchUser(currentUserId);
    } else {
      LikedUserManager.instance.initialize();
    }

    _loadUsers();
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
          index = 0;
          isLoading = false;
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
    return const AssetImage('assets/images/profile.png');
  }

  Future<void> _toggleLike(PublicUserProfile user) async {
    final nowLiked = await LikedUserManager.instance.toggle(user.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowLiked ? 'Liked' : 'Unliked'),
        backgroundColor: primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );

    setState(() {});
  }

  void _prev() {
    if (users.isEmpty) return;
    setState(() {
      index = (index - 1) < 0 ? users.length - 1 : index - 1;
    });
  }

  void _next() {
    if (users.isEmpty) return;
    setState(() {
      index = (index + 1) % users.length;
    });
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
        backgroundColor: const Color(0xFFF7FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Users',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/profile.png',
                      width: 20,
                      height: 20,
                      color: primaryGreen.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Browse user profiles',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!isLoading && errorMessage == null && users.isNotEmpty)
                      Text(
                        '${index + 1}/${users.length}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
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
    final user = users[index];
    final liked = LikedUserManager.instance.isLiked(user.id);

    return Row(
      children: [
        IconButton(
          onPressed: _prev,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            width: 18,
            height: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: _avatarProvider(user.photoBase64),
                      backgroundColor: const Color(0xFFF7FAFC),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primaryGreen.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if ((user.phone ?? '').trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/call.png',
                                    width: 16,
                                    height: 16,
                                    color: primaryGreen.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      user.phone!.trim(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if ((user.email ?? '').trim().isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/msg.png',
                                  width: 16,
                                  height: 16,
                                  color: primaryGreen.withValues(alpha: 0.85),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    user.email!.trim(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _toggleLike(user),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: liked ? primaryGreen : Colors.grey.shade400,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Image.asset(
                                'assets/images/star.png',
                                width: 20,
                                height: 20,
                                color: liked ? primaryGreen : Colors.grey,
                              ),
                              label: Text(
                                liked ? 'Liked' : 'Like',
                                style: TextStyle(
                                  color: liked ? primaryGreen : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
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
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: _next,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          icon: Image.asset(
            'assets/images/right-arrow.png',
            width: 18,
            height: 18,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
