import 'package:flutter/material.dart';
import 'home.dart';
import 'saved.dart';
import 'profile_pages/personal_info.dart';
import 'profile_pages/notifications.dart';
import 'profile_pages/change_password.dart';
import 'profile_pages/contact_us.dart';
import 'profile_pages/help_center.dart';
import 'profile_pages/report_problem.dart';
import 'profile_pages/about_us.dart';
import 'profile_pages/privacy_policy.dart';
import 'profile_pages/terms_conditions.dart';
import 'search.dart';
import 'profile_pages/edit_profile.dart';
import 'user_session.dart';
import 'saved_manager.dart';
import 'main.dart';
import 'dart:convert';
import 'saved_job_manager.dart';
import 'package:http/http.dart' as http;
import 'services/api_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  void initState() {
    super.initState();
    _refreshProfileFromServer();
  }

  Future<void> _refreshProfileFromServer() async {
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) return;

    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
      if (data is! Map) return;

      await UserSession.instance.updateProfile(
        name: data['name']?.toString(),
        phone: data['phone']?.toString(),
        photoBase64: data['photo']?.toString(),
      );
      if (mounted) setState(() {});
    } catch (_) {
      // ignore network errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final sess = UserSession.instance;
    final displayName = (sess.name != null && sess.name!.trim().isNotEmpty)
        ? sess.name!.trim()
        : 'User';
    final displayPhone = (sess.phone != null && sess.phone!.trim().isNotEmpty)
        ? sess.phone!.trim()
        : (sess.email ?? '');

    ImageProvider avatarProvider() {
      final photo = sess.photoBase64;
      if (photo != null && photo.isNotEmpty) {
        try {
          final raw = photo.contains(',') ? photo.split(',').last : photo;
          return MemoryImage(base64Decode(raw));
        } catch (_) {}
      }
      return const AssetImage('assets/images/profile.png');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: avatarProvider(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayPhone,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/edit.png',
                      width: 16,
                      height: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 ACCOUNT SETTINGS
            _sectionTitle("ACCOUNT SETTINGS"),
            _menuCard([
              _menuItem(
                'assets/images/profile.png',
                "Personal Information",
                const PersonalInformationPage(),
              ),
              _menuItem(
                'assets/images/bookmark.png',
                "Saved Listings",
                const SavedPage(),
              ),
              _menuItem(
                'assets/images/bell.png',
                "Notifications",
                const NotificationsPage(),
              ),
              _menuItem(
                'assets/images/lock.png',
                "Change Password",
                const ChangePasswordPage(),
              ),
            ]),

            const SizedBox(height: 16),

            /// 🔹 SUPPORT & HELP
            _sectionTitle("SUPPORT & HELP"),
            _menuCard([
              _menuItem(
                'assets/images/contact.png',
                "Contact Us",
                const ContactUsPage(),
              ),
              _menuItem(
                'assets/images/help.png',
                "Help Center",
                const HelpCenterPage(),
              ),
              _menuItem(
                'assets/images/warning.png',
                "Report a Problem",
                const ReportProblemPage(),
              ),
            ]),

            const SizedBox(height: 16),

            /// 🔹 APP INFORMATION
            _sectionTitle("APP INFORMATION"),
            _menuCard([
              _menuItem(
                'assets/images/info.png',
                "About Us",
                const AboutUsPage(),
              ),
              _menuItem(
                'assets/images/privacy.png',
                "Privacy Policy",
                const PrivacyPolicyPage(),
              ),
              _menuItem(
                'assets/images/terms.png',
                "Terms & Conditions",
                const TermsConditionsPage(),
              ),
            ]),

            const SizedBox(height: 20),

            /// 🔴 LOGOUT BUTTON (FIXED)
            OutlinedButton.icon(
              onPressed: () async {
                await UserSession.instance.clear();
                SavedManager.instance.clearCurrentUser();
                await SavedJobManager.instance.switchUser('guest');
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
              icon: Image.asset(
                'assets/images/logout.png',
                width: 18,
                height: 18,
                color: Colors.red,
              ),
              label: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFFF8D7DA),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),

      /// 🔹 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const SearchPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const SavedPage()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/home.png', height: 24),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/search.png', height: 24),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/bookmark.png', height: 24),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/profile.png', height: 24),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }

  Widget _menuItem(
    String iconPath,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Image.asset(iconPath,
          width: 22, height: 22, color: primaryGreen),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Image.asset(
        'assets/images/right-arrow.png',
        width: 18,
        height: 18,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
