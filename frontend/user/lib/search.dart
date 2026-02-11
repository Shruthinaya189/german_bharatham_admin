import 'package:flutter/material.dart';
import 'home.dart';
import 'saved.dart';
import 'profile.dart';
import 'job_details.dart';
import 'accommodation_details.dart';
import 'food_details.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedTab = 0;
  int bottomIndex = 1;

  final tabs = ["All", "Accommodation", "Food", "Jobs", "Services"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
  title: const Text("Search"),
  centerTitle: true,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,

  automaticallyImplyLeading: false,
  leading: null,
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            const SizedBox(height: 14),
            _categoryTabs(),
            const SizedBox(height: 20),

            if (selectedTab == 0 || selectedTab == 1) ...[
              _sectionHeader("Popular Accommodations"),
              _accommodationCard(),
              _accommodationCard(),
              const SizedBox(height: 18),
            ],

            if (selectedTab == 0 || selectedTab == 3) ...[
              _sectionHeader("New Jobs"),
              _jobCard(),
              _jobCard(),
              const SizedBox(height: 18),
            ],

            if (selectedTab == 0 || selectedTab == 2) ...[
              _sectionHeader("Famous Food & Grocery"),
              _foodCard(),
              _foodCard(),
              const SizedBox(height: 18),
            ],

            if (selectedTab == 0 || selectedTab == 4) ...[
              _sectionHeader("Services"),
              _serviceCard(),
              _serviceCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  /// 🔍 SEARCH BAR
  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search anything...",
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/search.png', width: 20),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 🔘 CATEGORY TABS
  Widget _categoryTabs() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => selectedTab = index),
            child: _chip(tabs[index], selectedTab == index),
          );
        },
      ),
    );
  }

  Widget _chip(String text, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF4E7F6D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 📌 SECTION HEADER
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Text("View all",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  /// 🏠 ACCOMMODATION CARD
  Widget _accommodationCard() {
    return _commonCard(
      image: 'assets/images/room.jpg',
      title: "Studio Apartment near University",
      subtitle: "Munich, Bavaria",
      rating: "4.5",
      trailing: "€24 / month",
    );
  }

  /// 💼 JOB CARD
  Widget _jobCard() {
    return _commonCard(
      image: 'assets/images/google.png',
      title: "Software Developer",
      subtitle: "Munich, Bavaria",
      rating: "4.5",
      trailing: "€55,000 - €70,000/year",
    );
  }

  /// 🍔 FOOD CARD
  Widget _foodCard() {
    return _commonCard(
      image: 'assets/images/restaurant.jpg',
      title: "Taj Mahal Restaurant",
      subtitle: "Munich, Bavaria",
      rating: "4.5",
    );
  }

  /// 🛠 SERVICE CARD
  Widget _serviceCard() {
    return _commonCard(
      image: 'assets/images/movers.jpg',
      title: "Relocation Experts",
      subtitle: "Munich, Bavaria",
      rating: "4.5",
    );
  }

  /// 🔁 COMMON CARD UI
  Widget _commonCard({
    required String image,
    required String title,
    required String subtitle,
    required String rating,
    String? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset('assets/images/location.png',
                        width: 14, height: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset('assets/images/star.png',
                        width: 14, height: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    if (trailing != null)
                      Text(trailing,
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          ),
          Image.asset('assets/images/bookmark.png',
              width: 18, height: 18, color: Colors.grey),
        ],
      ),
    );
  }

  /// 🔻 CUSTOM BOTTOM NAV
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          }
          if (index == 2) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const SavedPage()));
          }
          if (index == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/home.png', height: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/search.png', height: 24),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/bookmark.png', height: 24),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/profile.png', height: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
