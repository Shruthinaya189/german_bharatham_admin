import 'package:flutter/material.dart';
import 'accommodation_details.dart';
import 'filter_page.dart';

/// =======================
/// DATA MODEL
/// =======================
class Accommodation {
  final String title;
  final String location;
  final String image;
  final double rating;
  final int price;
  final List<String> features;   // 👈 ADD THIS
  bool isSaved;

  Accommodation({
    required this.title,
    required this.location,
    required this.image,
    required this.rating,
    required this.price,
    required this.features,      // 👈 ADD THIS
    this.isSaved = false,
  });
}


/// =======================
/// SAMPLE DATA
/// =======================
final List<Accommodation> accommodations = [
  Accommodation(
  title: "Studio Apartment near University",
  location: "Munich, Bavaria",
  image: "assets/images/room.jpg",
  rating: 4.5,
  price: 24,
  features: ["Furnished", "Kitchen", "Balcony"], // 👈 ADD
),

  Accommodation(
  title: "Studio Apartment near University",
  location: "Munich, Bavaria",
  image: "assets/images/room.jpg",
  rating: 4.5,
  price: 24,
  features: ["Furnished", "Kitchen", "Balcony"], // 👈 ADD
),

  Accommodation(
  title: "Studio Apartment near University",
  location: "Munich, Bavaria",
  image: "assets/images/room.jpg",
  rating: 4.5,
  price: 24,
  features: ["Furnished", "Kitchen", "Balcony"], // 👈 ADD
),

];

/// =======================
/// ACCOMMODATION PAGE
/// =======================
class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text("Accommodation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            height: 20,
            width: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Accomodtions",
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
                GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FilterPage(),
      ),
    );
  },
  child: Container(
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
  ),
)
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: accommodations.length,
              itemBuilder: (context, index) {
                final item = accommodations[index];

                return AccommodationCard(
                  accommodation: item,
                  onBookmarkTap: () {
                    setState(() {
                      item.isSaved = !item.isSaved;
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AccommodationDetailPage(item: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// ACCOMMODATION CARD
/// =======================
class AccommodationCard extends StatelessWidget {
  final Accommodation accommodation;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  const AccommodationCard({
    super.key,
    required this.accommodation,
    required this.onBookmarkTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                accommodation.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE + BOOKMARK
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          accommodation.title,
                          style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600,letterSpacing: 0.2,),
                        ),
                      ),
                      InkWell(
                        onTap: onBookmarkTap,
                        child: Image.asset(
                          'assets/images/bookmark.png',
                          width: 18,
                          height: 18,
                          color: accommodation.isSaved
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// LOCATION
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
                        accommodation.location,
                        style: const TextStyle(color: Color(0xFF6B7280),fontSize: 12,fontWeight: FontWeight.w400,),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  /// FEATURES
Wrap(
  spacing: 6,
  runSpacing: 6,
  children: accommodation.features.map((feature) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        feature,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }).toList(),
),
                  /// RATING + PRICE
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/star.png',
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        accommodation.rating.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        "€${accommodation.price} / month",
                        style: const TextStyle(color: Color(0xFF16A34A),fontWeight: FontWeight.w700,fontSize: 13,),
                      ),
                    ],
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
