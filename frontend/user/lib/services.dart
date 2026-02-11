import 'package:flutter/material.dart';
import 'service_details.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            height: 22,
            width: 22,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Services",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search + filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Services",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/search.png',
                          height: 20,
                          width: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/sort.png',
                    height: 22,
                    width: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// 🏷 Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  CategoryChip(title: "All", isSelected: true),
                  CategoryChip(title: "Home Services"),
                  CategoryChip(title: "Tuition & Coaching"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 📋 Services list
            Expanded(
              child: ListView(
                children: const [
                  ServiceCard(
                    image:
                        "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
                    title: "German Language Academy",
                    category: "Education",
                  ),
                  ServiceCard(
                    image:
                        "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
                    title: "Relocation Experts",
                    category: "Relocation",
                  ),
                  ServiceCard(
                    image:
                        "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
                    title: "Relocation Experts",
                    category: "Relocation",
                  ),
                  ServiceCard(
                    image:
                        "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
                    title: "Relocation Experts",
                    category: "Relocation",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🟢 Category Chip Widget
class CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4F7F67) : const Color(0xFFEFF3F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 📄 Service Card Widget
class ServiceCard extends StatelessWidget {
  final String image;
  final String title;
  final String category;

  const ServiceCard({
    super.key,
    required this.image,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ServiceDetailsPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/location.png',
                        height: 14,
                        width: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Munich, Bavaria",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/star.png',
                        height: 14,
                        width: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text("4.5"),
                    ],
                  ),
                ],
              ),
            ),

            /// Bookmark
            Image.asset(
              'assets/images/bookmark.png',
              height: 20,
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}
