import 'package:flutter/material.dart';
import 'food_details.dart';

class FoodGroceryPage extends StatelessWidget {
  const FoodGroceryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            height: 22,
            width: 22,
            color: Colors.black,
          ),
        ),
        title: const Text("Food & Grocery"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Food & grocery",
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/sort.png',
                    height: 22,
                    width: 22,
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            /// 📋 List
            Expanded(
              child: ListView(
                children: const [
                  FoodCard(
                    name: "Taj Mahal Restaurant",
                    location: "Munich, Bavaria",
                    rating: "4.5",
                    distance: "1.2km",
                    image: "assets/images/food1.jpg",
                  ),
                  FoodCard(
                    name: "Namaste Indian Grocery",
                    location: "Munich, Bavaria",
                    rating: "4.5",
                    distance: "1.2km",
                    image: "assets/images/food2.jpg",
                  ),
                  FoodCard(
                    name: "Namaste Indian Grocery",
                    location: "Munich, Bavaria",
                    rating: "4.5",
                    distance: "1.2km",
                    image: "assets/images/food2.jpg",
                  ),
                  FoodCard(
                    name: "Taj Mahal Restaurant",
                    location: "Munich, Bavaria",
                    rating: "4.5",
                    distance: "1.2km",
                    image: "assets/images/food1.jpg",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String name;
  final String location;
  final String rating;
  final String distance;
  final String image;

  const FoodCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.distance,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailPage(
              name: name,
              image: image,
              rating: rating,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/location.png',
                        height: 14,
                        width: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
                      Text(rating,
                          style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Image.asset(
                        'assets/images/location.png',
                        height: 14,
                        width: 14,
                      ),
                      Text(distance,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
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
