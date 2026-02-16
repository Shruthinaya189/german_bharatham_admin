import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'search.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _currentIndex = 2;
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      /// BODY
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// CATEGORY ROW
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategory("All", 0),
                _buildCategory("Accommodation", 1),
                _buildCategory("Food", 2),
                _buildCategory("Jobs", 3),
                _buildCategory("Services", 4),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// SAVED CARDS
          const SavedCard(
            title: "Studio Apartment near University",
            location: "Munich, Bavaria",
            rating: "4.5",
            status: "Booked",
            statusColor: Colors.red,
            image: 'assets/images/room.jpg',
          ),
          const SavedCard(
            title: "Studio Apartment near University",
            location: "Munich, Bavaria",
            rating: "4.5",
            status: "Available",
            statusColor: Colors.green,
            image: 'assets/images/room.jpg',
          ),
          const SavedCard(
            title: "Relocation Experts",
            location: "Munich, Bavaria",
            rating: "4.5",
            image: 'assets/images/movers.jpg',
          ),
          const SavedCard(
            title: "Taj Mahal Restaurant",
            location: "Munich, Bavaria",
            rating: "4.5",
            image: 'assets/images/restaurant.jpg',
          ),
        ],
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
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

  /// CATEGORY BUTTON
  Widget _buildCategory(String title, int index) {
    final bool isSelected = _selectedCategory == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A7D6B) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class SavedCard extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final String image;
  final String? status;
  final Color? statusColor;

  const SavedCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.image,
    this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/bookmark.png',
                      width: 18,
                      height: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/location.png',
                      width: 14,
                      height: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/star.png',
                      width: 14,
                      height: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
