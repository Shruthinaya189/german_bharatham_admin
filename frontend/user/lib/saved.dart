import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'search.dart';
import 'accommodation.dart';
import 'accommodation_details.dart';
import 'guide_details.dart';
import 'models/community_model.dart';
import 'saved_manager.dart';
import 'saved_guides_manager.dart';

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
    final savedAccommodations = SavedManager.instance.savedAccommodations;

    List<Accommodation> displayedAccommodations = [];
    if (_selectedCategory == 0 || _selectedCategory == 1) {
      displayedAccommodations = List.from(savedAccommodations);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      /// BODY
      body: Column(
        children: [
          /// CATEGORY ROW
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
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
          ),

          const SizedBox(height: 12),

          /// SAVED ITEMS LIST
          Expanded(
            child: FutureBuilder<List<CommunityPost>>(
              future: SavedGuidesManager.instance.getSavedItems(),
              builder: (context, snapshot) {
                final savedGuides = snapshot.data ?? const <CommunityPost>[];
                final displayedGuides =
                    _selectedCategory == 0 ? savedGuides : const <CommunityPost>[];

                final isEmpty =
                    displayedAccommodations.isEmpty && displayedGuides.isEmpty;

                if (isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/bookmark.png',
                          height: 48,
                          width: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No saved items yet",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tap the bookmark icon on any listing to save it",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final totalCount =
                    displayedAccommodations.length + displayedGuides.length;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: totalCount,
                  itemBuilder: (context, index) {
                    if (index < displayedAccommodations.length) {
                      final item = displayedAccommodations[index];
                      return _SavedAccommodationCard(
                        item: item,
                        onRemove: () {
                          setState(() {
                            SavedManager.instance.toggle(item);
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
                    }

                    final guide =
                        displayedGuides[index - displayedAccommodations.length];

                    return _SavedGuideCard(
                      guide: guide,
                      onRemove: () async {
                        await SavedGuidesManager.instance.toggle(guide);
                        if (!context.mounted) return;
                        setState(() {});
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuideDetailsPage(guide: guide),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
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

/// Card for displaying a saved accommodation
class _SavedAccommodationCard extends StatelessWidget {
  final Accommodation item;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedAccommodationCard({
    required this.item,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.image.startsWith('http')
                  ? Image.network(
                      item.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : Image.asset(
                      item.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
            ),
            const SizedBox(width: 12),

            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      /// REMOVE (unsave) button
                      InkWell(
                        onTap: onRemove,
                        child: Image.asset(
                          'assets/images/bookmark.png',
                          width: 18,
                          height: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/location.png',
                        width: 13,
                        height: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/star.png',
                        width: 13,
                        height: 13,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (item.averageRating ?? 0.0).toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      if (item.price > 0)
                        Text(
                          "€${item.price}/mo",
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
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

  Widget _placeholder() => Container(
        width: 80,
        height: 80,
        color: const Color(0xFFE8F5E9),
        child: const Icon(Icons.home, color: Color(0xFF4F7F67)),
      );
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

class _SavedGuideCard extends StatelessWidget {
  final CommunityPost guide;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedGuideCard({
    required this.guide,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    guide.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onRemove,
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "${guide.author} • ${guide.date}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}