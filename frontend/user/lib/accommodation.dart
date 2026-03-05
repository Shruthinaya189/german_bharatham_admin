import 'package:flutter/material.dart';
import 'accommodation_details.dart';
import 'filter_page.dart';
import 'saved_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Use machine IP for real device, 10.0.2.2 for emulator
const String apiBaseUrl = 'http://10.233.141.31:5000';

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
  final List<String> highlights;
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
  final double? avgRating;
  final List<Map<String, dynamic>> reviews;

  Accommodation({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.image,
    required this.rating,
    required this.price,
    required this.amenities,
    required this.highlights,
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
    this.avgRating,
    List<Map<String, dynamic>>? reviews,
  }) : reviews = reviews ?? [];

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

    // Extract highlights
    List<String> extractedHighlights = [];
    if (json['highlights'] != null && json['highlights'] is List) {
      extractedHighlights = List<String>.from(json['highlights']);
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
      if (json['area'] != null && json['area'].toString().isNotEmpty) {
        location += ', ${json['area']}';
      }
    }

    // Get property type
    String propertyType = json['propertyType'] ?? 'shared_rooms';
    String formattedPropertyType = propertyType.replaceAll('_', ' ').split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');

    return Accommodation(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      location: location.isNotEmpty ? location : 'Location not specified',
      image: (json['media']?['images'] != null && 
             (json['media']['images'] as List).isNotEmpty)
          ? json['media']['images'][0]
          : 'assets/images/room.jpg',
      rating: 4.5, // Default rating since it's not in schema
      price: displayPrice,
      amenities: extractedAmenities.take(3).toList(),
      highlights: extractedHighlights,
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
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      reviews: json['reviews'] != null
          ? List<Map<String, dynamic>>.from(json['reviews'])
          : [],
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
        List<dynamic> data = json.decode(response.body);
        final loaded = data
            .map((j) => Accommodation.fromJson(j))
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: accommodation.image.startsWith('http')
                  ? Image.network(
                      accommodation.image,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : Image.asset(
                      accommodation.image,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
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
                              ? Colors.black
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
                  
                  /// HIGHLIGHTS (if available)
                  if (accommodation.highlights.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: accommodation.highlights.take(2).map((highlight) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF28a745),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '★',
                                  style: TextStyle(fontSize: 10, color: Colors.red),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  highlight,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  /// AMENITIES
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: accommodation.amenities.map((amenity) {
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
                          amenity,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 6),
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
                        (accommodation.avgRating ?? accommodation.rating)
                            .toStringAsFixed(1),
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

  static Widget _placeholderImage() => Container(
        width: 90,
        height: 90,
        color: const Color(0xFFE8F5E9),
        child: const Icon(Icons.home, color: Color(0xFF4F7F67), size: 36),
      );
}
