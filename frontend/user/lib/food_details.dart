import 'package:flutter/material.dart';

class FoodDetailPage extends StatelessWidget {
  final String name;
  final String image;
  final String rating;

  const FoodDetailPage({
    super.key,
    required this.name,
    required this.image,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE HEADER
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                      child: Image.asset(
                        image,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// BACK BUTTON
                    Positioned(
                      top: 42,
                      left: 16,
                      child: _circleBtn(
                        iconPath: 'assets/images/left-arrow.png',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),

                    /// BOOKMARK + SHARE
                    Positioned(
                      top: 42,
                      right: 16,
                      child: Row(
                        children: const [
                          _CircleIcon(iconPath: 'assets/images/bookmark.png'),
                          SizedBox(width: 12),
                          _CircleIcon(iconPath: 'assets/images/share.png'),
                        ],
                      ),
                    ),
                  ],
                ),

                /// CONTENT
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE + RATING
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/star.png',
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            rating,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// ADDRESS
                      _infoRow(
                        icon: 'assets/images/location.png',
                        title: "Address",
                        value: "Marienplatz 45, 80331 Munich",
                      ),

                      const SizedBox(height: 16),

                      /// TIME
                      _infoRow(
                        icon: 'assets/images/time.png',
                        title: "Time",
                        value: "Daily: 11:00 AM - 11:00 PM",
                      ),

                      const SizedBox(height: 26),

                      /// SERVICES
                      const Text(
                        "Services",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                          _Chip("Dine-in"),
                          _Chip("Home Delivery"),
                          _Chip("Catering"),
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// MAP
                      const Text(
                        "Location",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/map.jpeg',
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// CALL BUTTON
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/call.png',
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  "Call",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white, // ✅ FIXED HERE
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  backgroundColor: const Color(0xFF4F7F67),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CIRCULAR ICON BUTTON
  Widget _circleBtn({
    required String iconPath,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }

  /// INFO ROW
  static Widget _infoRow({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, height: 20, width: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Reusable circle icon (for const usage)
class _CircleIcon extends StatelessWidget {
  final String iconPath;

  const _CircleIcon({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          iconPath,
          height: 20,
          width: 20,
        ),
      ),
    );
  }
}

/// SERVICE CHIP
class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
