import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'accommodation.dart';
import 'saved_manager.dart';

class AccommodationDetailPage extends StatefulWidget {
  final Accommodation item;

  const AccommodationDetailPage({super.key, required this.item});

  @override
  State<AccommodationDetailPage> createState() =>
      _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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
                      child: _buildHeaderImage(item.image),
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
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                SavedManager.instance.toggle(item);
                              });
                            },
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
                                  'assets/images/bookmark.png',
                                  height: 20,
                                  width: 20,
                                  color: item.isSaved
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/star.png',
                            height: 18,
                            width: 18,
                            color: const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (item.averageRating ?? 0.0).clamp(0.0, 5.0).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// LOCATION
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/location.png', height: 22, width: 22,
                              errorBuilder: (_, __, ___) => const Icon(Icons.location_on, size: 22, color: Color(0xFF4F7F67))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Location',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(item.location,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// RENT / PRICE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/rent.png', height: 22, width: 22,
                              errorBuilder: (_, __, ___) => const Icon(Icons.euro_rounded, size: 22, color: Color(0xFF4F7F67))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rent',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                item.warmRent != null
                                    ? '€${item.warmRent} / month'
                                    : '€${item.price} / month',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// PROPERTY TYPE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/propertytype.png', height: 22, width: 22,
                              errorBuilder: (_, __, ___) => const Icon(Icons.home_work_outlined, size: 22, color: Color(0xFF4F7F67))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Property Type',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(item.propertyType,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),

                      /// PROPERTY DETAILS
                      if (item.bedrooms != null ||
                          item.bathrooms != null ||
                          item.sizeSqm != null) ...[
                        const SizedBox(height: 26),
                        const Text(
                          "Property Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (item.bedrooms != null)
                              _Chip("🛏 ${item.bedrooms} Bedroom${item.bedrooms! > 1 ? 's' : ''}"),
                            if (item.bathrooms != null)
                              _Chip("🚿 ${item.bathrooms} Bathroom${item.bathrooms! > 1 ? 's' : ''}"),
                            if (item.sizeSqm != null)
                              _Chip("📐 ${item.sizeSqm} sqm"),
                            if (item.totalFloors != null)
                              _Chip("🏢 ${item.totalFloors} Floor${item.totalFloors! > 1 ? 's' : ''}"),
                          ],
                        ),
                      ],

                      /// RENT BREAKDOWN
                      if (item.coldRent != null || item.deposit != null) ...[
                        const SizedBox(height: 26),
                        const Text(
                          "Rent Breakdown",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (item.coldRent != null)
                              _Chip("Cold Rent: €${item.coldRent}"),
                            if (item.warmRent != null)
                              _Chip("Warm Rent: €${item.warmRent}"),
                            if (item.additionalCosts != null)
                              _Chip("Additional: €${item.additionalCosts}"),
                            if (item.deposit != null)
                              _Chip("Deposit: €${item.deposit}"),
                          ],
                        ),
                      ],

                      /// UTILITIES INCLUDED
                      if ((item.electricityIncluded == true) ||
                          (item.heatingIncluded == true) ||
                          (item.internetIncluded == true)) ...[
                        const SizedBox(height: 26),
                        const Text(
                          "Included Utilities",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (item.electricityIncluded == true)
                              _Chip("⚡ Electricity"),
                            if (item.heatingIncluded == true)
                              _Chip("🔥 Heating"),
                            if (item.internetIncluded == true)
                              _Chip("📶 Internet"),
                          ],
                        ),
                      ],

                      /// NEARBY
                      if ((item.nearUniversity == true) ||
                          (item.nearSupermarket == true) ||
                          (item.nearHospital == true) ||
                          (item.nearPublicTransport == true)) ...[
                        const SizedBox(height: 26),
                        const Text(
                          "Nearby",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (item.nearUniversity == true)
                              _Chip("🎓 University"),
                            if (item.nearSupermarket == true)
                              _Chip("🛒 Supermarket"),
                            if (item.nearHospital == true)
                              _Chip("🏥 Hospital"),
                            if (item.nearPublicTransport == true)
                              _Chip("🚌 Public Transport"),
                          ],
                        ),
                      ],

                      /// AMENITIES
                      if (item.amenities.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        const Text(
                          "Amenities",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: item.amenities.map((a) => _Chip(a)).toList(),
                        ),
                      ],

                      /// DESCRIPTION
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.description
                              .replaceAll(RegExp(r'^\s*Description\s*\*?\s*\n?', caseSensitive: false), '')
                              .replaceAll(RegExp(r'^\*+|\*+$'), '')
                              .trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.6,
                          ),
                        ),
                      ],

                      const SizedBox(height: 26),

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
                          errorBuilder: (_, __, ___) => Container(
                            height: 190,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 60,
                                color: Color(0xFF4F7F67),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),


                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// CONTACT BUTTONS (floating at bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final phone = item.contactPhone;
                        if (phone != null && phone.isNotEmpty) {
                          final uri = Uri(scheme: 'tel', path: phone);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No contact number available')),
                          );
                        }
                      },
                      icon: Image.asset(
                        'assets/images/call.png',
                        height: 22,
                        width: 22,
                      ),
                      label: const Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: const Color(0xFF4F7F67),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                /// WHATSAPP BUTTON
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final phone = item.contactPhone;
                        if (phone != null && phone.isNotEmpty) {
                          // Strip non-digits except leading +
                          final cleaned = phone.replaceAll(RegExp(r'[\s\-()]+'), '');
                          final uri = Uri.parse('https://wa.me/$cleaned');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No contact number available')),
                          );
                        }
                      },
                      icon: Image.asset(
                        'assets/images/whatsapp.png',
                        height: 22,
                        width: 22,
                      ),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: const Color(0xFF4F7F67),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 300,
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.home, size: 80, color: Color(0xFF4F7F67)),
    );
  }

  /// Handles base64 data-URI, network URL, and asset path
  static Widget _buildHeaderImage(String src) {
    if (src.startsWith('data:image')) {
      try {
        final Uint8List bytes = base64Decode(src.split(',').last);
        return Image.memory(bytes,
            width: double.infinity, height: 300, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholderImage());
      } catch (_) {}
    }
    if (src.startsWith('http')) {
      return Image.network(src,
          width: double.infinity, height: 300, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderImage());
    }
    return Image.asset(src,
        width: double.infinity, height: 300, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage());
  }

  static Widget _circleBtn({
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
          child: Image.asset(iconPath, height: 20, width: 20),
        ),
      ),
    );
  }

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

/// Reusable circle icon (bookmark/share)
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
        child: Image.asset(iconPath, height: 20, width: 20),
      ),
    );
  }
}

/// Label chip (for amenities, features, etc.)
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

