import 'package:flutter/material.dart';
import 'accommodation_details.dart';
import 'filter_page.dart';
import 'saved_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

// Use machine IP for real device, 10.0.2.2 for emulator
const String apiBaseUrl = 'http://10.96.191.169:5000';

/// =======================
/// DATA MODEL
/// =======================
class Accommodation {
  final String id;
  final String title;
  final String description;
  final String location;
  final String image;
  final double rating;
  final int price;
  final List<String> amenities;
  final String propertyType;
  final double? latitude;
  final double? longitude;
  bool isSaved;
  
  // MongoDB nested fields
  final int? bedrooms;
  final int? bathrooms;
  final int? sizeSqm;
  final int? totalFloors;
  final int? coldRent;
  final int? warmRent;
  final int? additionalCosts;
  final int? deposit;
  final bool? electricityIncluded;
  final bool? heatingIncluded;
  final bool? internetIncluded;
  final bool? nearUniversity;
  final bool? nearSupermarket;
  final bool? nearHospital;
  final bool? nearPublicTransport;
  final String? contactPhone;
  final double? averageRating;

  Accommodation({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.image,
    required this.rating,
    required this.price,
    required this.amenities,
    required this.propertyType,
    this.latitude,
    this.longitude,
    this.isSaved = false,
    this.bedrooms,
    this.bathrooms,
    this.sizeSqm,
    this.totalFloors,
    this.coldRent,
    this.warmRent,
    this.additionalCosts,
    this.deposit,
    this.electricityIncluded,
    this.heatingIncluded,
    this.internetIncluded,
    this.nearUniversity,
    this.nearSupermarket,
    this.nearHospital,
    this.nearPublicTransport,
    this.contactPhone,
    this.averageRating,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    // Extract amenities from the amenities object
    List<String> extractedAmenities = [];
    if (json['amenities'] != null) {
      Map<String, dynamic> amenities = json['amenities'];
      amenities.forEach((key, value) {
        if (value == true) {
          // Convert camelCase to readable format
          String formatted = key.replaceAllMapped(
            RegExp(r'([A-Z])'),
            (Match m) => ' ${m[0]}'
          ).trim();
          formatted = formatted[0].toUpperCase() + formatted.substring(1);
          extractedAmenities.add(formatted);
        }
      });
    }

    // Calculate price from rentDetails
    int displayPrice = 0;
    if (json['rentDetails'] != null) {
      displayPrice = (json['rentDetails']['warmRent'] ?? 
                     json['rentDetails']['coldRent'] ?? 0).toInt();
    }

    // Build location string
    String location = '';
    if (json['city'] != null) {
      location = json['city'].toString();
    }

    // Get property type
    String propertyType = json['propertyType'] ?? 'shared_rooms';
    String formattedPropertyType = propertyType.replaceAll('_', ' ').split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');

    return Accommodation(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled').toString(),
      description: (json['description'] ?? '').toString(),
      location: location.isNotEmpty ? location : 'Location not specified',
      image: (json['media']?['images'] != null && 
             (json['media']['images'] as List).isNotEmpty)
          ? (() {
              final img = json['media']['images'][0];
              if (img is String) return img;
              if (img is Map) return (img['url'] ?? img['uri'] ?? 'assets/images/room.jpg').toString();
              return 'assets/images/room.jpg';
            })()
          : 'assets/images/room.jpg',
      rating: 4.5, // Default rating since it's not in schema
      price: displayPrice,
      amenities: extractedAmenities.take(3).toList(),
      propertyType: formattedPropertyType,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isSaved: false,
      // Extract MongoDB nested fields
      bedrooms: json['propertyDetails']?['bedrooms'],
      bathrooms: json['propertyDetails']?['bathrooms'],
      sizeSqm: json['propertyDetails']?['sizeSqm'],
      totalFloors: json['propertyDetails']?['totalFloors'],
      coldRent: json['rentDetails']?['coldRent'],
      warmRent: json['rentDetails']?['warmRent'],
      additionalCosts: json['rentDetails']?['additionalCosts'],
      deposit: json['rentDetails']?['deposit'],
      electricityIncluded: json['rentDetails']?['electricityIncluded'],
      heatingIncluded: json['rentDetails']?['heatingIncluded'],
      internetIncluded: json['rentDetails']?['internetIncluded'],
      nearUniversity: json['locationHighlights']?['nearUniversity'],
      nearSupermarket: json['locationHighlights']?['nearSupermarket'],
      nearHospital: json['locationHighlights']?['nearHospital'],
      nearPublicTransport: json['locationHighlights']?['nearPublicTransport'],
      contactPhone: json['contactPhone']?.toString(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// =======================
/// ACCOMMODATION PAGE
/// =======================
class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  List<Accommodation> accommodations = [];
  List<Accommodation> filteredAccommodations = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAccommodations();
  }

  Future<void> fetchAccommodations() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/accommodation/user'),
        headers: {
          'x-user-id': 'user123',
          'x-user-role': 'user',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Support both plain array and wrapped { data: [...] } responses
        final List<dynamic> data =
            decoded is List ? decoded : (decoded['data'] ?? []) as List;
        final loaded = data
            .map((j) {
              try {
                return Accommodation.fromJson(j as Map<String, dynamic>);
              } catch (parseErr) {
                debugPrint('Skipping record due to parse error: $parseErr');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<Accommodation>()
            .toList();
        // restore saved state from SavedManager
        for (final acc in loaded) {
          acc.isSaved = SavedManager.instance.isSaved(acc.id);
        }
        setState(() {
          accommodations = loaded;
          filteredAccommodations = accommodations;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error ${response.statusCode}: ${response.body}')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void searchAccommodations(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredAccommodations = accommodations;
      } else {
        final q = query.toLowerCase();
        // Exact / direct matches first
        final exact = accommodations.where((acc) =>
            acc.title.toLowerCase().contains(q) ||
            acc.location.toLowerCase().contains(q) ||
            acc.description.toLowerCase().contains(q)).toList();
        // Similar: same property type as any exact match, not already in exact
        final exactIds = exact.map((e) => e.id).toSet();
        final exactTypes = exact.map((e) => e.propertyType.toLowerCase()).toSet();
        final similar = accommodations.where((acc) =>
            !exactIds.contains(acc.id) &&
            exactTypes.any((t) => acc.propertyType.toLowerCase().contains(t))).toList();
        filteredAccommodations = [...exact, ...similar];
      }
    });
  }

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
                    onChanged: searchAccommodations,
                    decoration: InputDecoration(
                      hintText: "Search Accommodations",
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
  onTap: () async {
    final result = await Navigator.push<List<Accommodation>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterPage(allAccommodations: accommodations),
      ),
    );
    if (result != null) {
      setState(() {
        filteredAccommodations = result;
      });
    }
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAccommodations.isEmpty
                    ? const Center(
                        child: Text(
                          'No accommodations found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredAccommodations.length,
              itemBuilder: (context, index) {
                final item = filteredAccommodations[index];

                return AccommodationCard(
                  accommodation: item,
                  onBookmarkTap: () {
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildListingImage(accommodation.image, 100, 100),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onBookmarkTap,
                        child: Icon(
                          accommodation.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 16,
                          color: accommodation.isSaved
                              ? const Color(0xFF4E7F6D)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// LOCATION
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          accommodation.location,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  
                  /// AMENITIES
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: accommodation.amenities.take(3).map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 8),
                  /// RATING + PRICE
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/star.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (accommodation.averageRating != null && accommodation.averageRating! > 0)
                            ? accommodation.averageRating!.toStringAsFixed(1)
                            : '4.5',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "€${accommodation.price} / per month",
                        style: const TextStyle(
                          color: Color(0xFF4E7F6D),
                          fontWeight: FontWeight.w600,
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

  static Widget _placeholderImage() => Container(
        width: 90,
        height: 90,
        color: const Color(0xFFE8F5E9),
        child: Image.asset(
          'assets/images/accommodation.png',
          width: 36,
          height: 36,
          color: const Color(0xFF4F7F67),
        ),
      );

  /// Handles URL, base64 data-URI and asset images
  static Widget _buildListingImage(String src, double w, double h) {
    if (src.startsWith('data:image')) {
      try {
        final Uint8List bytes = base64Decode(src.split(',').last);
        return Image.memory(bytes, width: w, height: h, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholderImage());
      } catch (_) {}
    }
    if (src.startsWith('http')) {
      return Image.network(src, width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholderImage());
    }
    return Image.asset(src, width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImage());
  }
}
