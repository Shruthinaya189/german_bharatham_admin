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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        AssetImage('assets/images/profile.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Ajay",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("+91 9363001215",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
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
                      );
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
              onPressed: () {},
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
