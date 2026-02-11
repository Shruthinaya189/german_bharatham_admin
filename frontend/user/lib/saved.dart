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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved"),
        centerTitle: true,
        automaticallyImplyLeading: false, // ✅ REMOVES BACK BUTTON
      ),

      // 🔹 BODY
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SavedCard(
            title: "Studio Apartment near University",
            location: "Munich, Bavaria",
            rating: "4.5",
            status: "Booked",
            statusColor: Colors.red,
            image: 'assets/images/room.jpg',
          ),
          SavedCard(
            title: "Studio Apartment near University",
            location: "Munich, Bavaria",
            rating: "4.5",
            status: "Available",
            statusColor: Colors.green,
            image: 'assets/images/room.jpg',
          ),
          SavedCard(
            title: "Relocation Experts",
            location: "Munich, Bavaria",
            rating: "4.5",
            image: 'assets/images/movers.jpg',
          ),
          SavedCard(
            title: "Taj Mahal Restaurant",
            location: "Munich, Bavaria",
            rating: "4.5",
            image: 'assets/images/restaurant.jpg',
          ),
        ],
      ),

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SavedPage()),
            );
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => SearchPage()),
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
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
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
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
