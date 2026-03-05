import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'models/food_grocery_model.dart';
import 'saved_food_manager.dart';

class FoodDetailPage extends StatefulWidget {
  final FoodGrocery item;
  final VoidCallback? onRefresh;

  const FoodDetailPage({
    super.key,
    required this.item,
    this.onRefresh,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = SavedFoodManager.instance.isSaved(widget.item.id);
  }

  Future<void> _toggleSave() async {
    final nowSaved = await SavedFoodManager.instance.toggle(widget.item);
    setState(() {
      isSaved = nowSaved;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nowSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF4E7F6D),
        ),
      );
    }
    
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  Future<void> _shareRestaurant() async {
    final String shareText = '''
${widget.item.title}
${widget.item.address}
Rating: ${widget.item.averageRating > 0 ? widget.item.averageRating.toStringAsFixed(1) : '4.5'} ⭐
${widget.item.phone != null && widget.item.phone!.isNotEmpty ? 'Phone: ${widget.item.phone}' : ''}
''';
    
    try {
      await Share.share(shareText, subject: widget.item.title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    if (widget.item.phone == null || widget.item.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: widget.item.phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// IMAGE HEADER
            Stack(
              children: [
                _buildImage(widget.item.image, 300),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _circleIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 60,
                  child: _circleIcon(
                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                    onTap: _toggleSave,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _circleIcon(
                    icon: Icons.share,
                    onTap: _shareRestaurant,
                  ),
                ),
              ],
            ),

            /// CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE + RATING
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.averageRating > 0
                                  ? widget.item.averageRating.toStringAsFixed(1)
                                  : '4.5',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ADDRESS
                    _infoRow(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: widget.item.address,
                    ),

                    if (widget.item.openingHours != null && widget.item.openingHours!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _infoRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: widget.item.openingHours!,
                      ),
                    ],

                    if (widget.item.priceRange != null && widget.item.priceRange!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.item.priceRange!.replaceAll('\$', ''),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    /// SERVICES
                    const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (widget.item.dineInAvailable) const _ServiceChip(text: "Dine-in"),
                        if (widget.item.deliveryAvailable) const _ServiceChip(text: "Home Delivery"),
                        if (widget.item.takeoutAvailable) const _ServiceChip(text: "Takeout"),
                        if (widget.item.cateringAvailable) const _ServiceChip(text: "Catering"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// LOCATION MAP
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/map.jpeg',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// CALL BUTTON
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(context),
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    "Call",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E7F6D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, double height) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _placeholderImage(height);
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderImage(height),
      );
    } else {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderImage(height),
      );
    }
  }

  Widget _placeholderImage(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFFE8F5E9),
      child: const Icon(
        Icons.restaurant,
        color: Color(0xFF4E7F6D),
        size: 80,
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4E7F6D)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// SERVICE CHIP
class _ServiceChip extends StatelessWidget {
  final String text;

  const _ServiceChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
