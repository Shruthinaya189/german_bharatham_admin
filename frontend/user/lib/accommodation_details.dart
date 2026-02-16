import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccommodationDetailPage extends StatelessWidget {
  final dynamic item;

  const AccommodationDetailPage({super.key, this.item});

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
                Image.asset(
                  item.image,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _circleIcon(
                    icon: 'assets/images/left-arrow.png',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _circleIcon(
                    icon: 'assets/images/share.png',
                    onTap: () {},
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
                    /// TITLE
                    Text(
                      item.title,
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// LOCATION + PRICE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/location.png',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.location,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF7A7A7A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "€${item.price} / per month",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4E7F6D),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// DESCRIPTION
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Modern 2-room apartment in the heart of Munich.\n"
                      "Close to public transport, shopping centers, and parks.\n"
                      "Perfect for students and young professionals.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6E6E6E),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// AMENITIES
                    const Text(
                      "Amenities",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _AmenityChip(text: "Furnished"),
                        _AmenityChip(text: "Kitchen"),
                        _AmenityChip(text: "Wifi"),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// LOCATION MAP
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

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

            /// BOTTOM BUTTONS
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _bottomButton(
                      icon: 'assets/images/call.png',
                      label: "Call",
                      color: const Color(0xFF4E7F6D),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _bottomButton(
                      icon: 'assets/images/whatsapp.png',
                      label: "Whatsapp",
                      color: const Color(0xFF4E7F6D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({required String icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.asset(icon, width: 18, height: 18),
      ),
    );
  }

  Widget _bottomButton({
    required String icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Image.asset(
        icon,
        width: 18,
        height: 18,
        color: Colors.white, // ✅ icon white
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white, // ✅ text white
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// AMENITY CHIP
class _AmenityChip extends StatelessWidget {
  final String text;

  const _AmenityChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}
