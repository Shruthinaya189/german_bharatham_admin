import 'package:flutter/material.dart';
import 'saved.dart';
import 'profile.dart';
import 'accommodation.dart';
import 'food_grocery.dart';
import 'jobs.dart';
import 'services.dart';
import 'community.dart';
import 'search.dart';
import 'user_session.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),

      // 🔹 BODY
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 16),
            _promoCard(),
            const SizedBox(height: 20),

            const Text(
              "Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            CategoryTile(
  imagePath: 'assets/images/accommodation.png',
  title: "Accommodation",
  subtitle: "Rooms & apartments for rent",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccommodationPage()),
    );
  },
),

CategoryTile(
  imagePath: 'assets/images/grocery-store.png',
  title: "Food & Grocery",
  subtitle: "Indian groceries & restaurants",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoodGroceryPage()),
    );
  },
),

CategoryTile(
  imagePath: 'assets/images/job-search.png',
  title: "Jobs",
  subtitle: "Part-time & full-time jobs",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JobsPage()),
    );
  },
),

CategoryTile(
  imagePath: 'assets/images/shift.png',
  title: "Services",
  subtitle: "Relocation & documentation help",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServicesPage()),
    );
  },
),

CategoryTile(
  imagePath: 'assets/images/handshake.png',
  title: "Community",
  subtitle: "Support & guides for Indians",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityPage()),
    );
  },
),
          ],
        ),
      ),

      // 🔹 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedPage()),
            ).then((_) {
              if (mounted) setState(() {});
            });
          }
          else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const SearchPage()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ).then((_) {
              if (mounted) setState(() {});
            });
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

  // 🔹 HEADER
 // 🔹 HEADER
Widget _header() {
  final sess = UserSession.instance;
  final displayName = (sess.name != null && sess.name!.trim().isNotEmpty)
      ? sess.name!.trim()
      : 'User';

  ImageProvider avatarProvider() {
    final photo = sess.photoBase64;
    if (photo != null && photo.isNotEmpty) {
      try {
        final raw = photo.contains(',') ? photo.split(',').last : photo;
        return MemoryImage(base64Decode(raw));
      } catch (_) {}
    }
    return const AssetImage('assets/images/person.jpeg');
  }

  return Row(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundImage: avatarProvider(),
      ),
      const SizedBox(width: 12),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // 🔔 Bell icon in header (NO AppBar)
      IconButton(
        icon: Image.asset(
          'assets/images/bell.png',
          width: 22,
          height: 22,
          color: HomePage.primaryGreen,
        ),
        onPressed: () {},
      ),
    ],
  );
}


  // 🔹 PROMO CARD
  Widget _promoCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePage.primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New to Germany? Start Here",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Guides & resources for Indians in Germany",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: HomePage.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: const Text("Get Started", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
  borderRadius: BorderRadius.circular(9),
  child: Image.asset(
    "assets/images/person.jpeg", // change to your image name
    width: 90,
    height: 110,
    fit: BoxFit.cover,
  ),
)
        ],
      ),
    );
  }
}

// 🔹 CATEGORY TILE
class CategoryTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: HomePage.primaryGreen.withOpacity(0.15),
            child: Image.asset(
              imagePath,
              width: 22,
              height: 22,
              color: HomePage.primaryGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Image.asset(
            'assets/images/right-arrow.png',
            width: 18,
            height: 18,
            color: Colors.grey,
          ),
        ],
      ),
      ),
    );
  }
}
