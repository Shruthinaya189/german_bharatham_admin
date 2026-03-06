import '../services/api_config.dart';

class Service {
  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return const [];
      return trimmed
          .split(RegExp(r'[,;\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _firstImageFromMedia(dynamic media) {
    try {
      if (media is Map) {
        final images = media['images'];
        if (images is List && images.isNotEmpty) {
          final first = images.first;
          if (first == null) return '';
          if (first is String) return first;
          if (first is Map) {
            return (first['url'] ?? first['uri'] ?? '').toString();
          }
          return first.toString();
        }
      }
    } catch (_) {}
    return '';
  }

  static String _normalizeStatus(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return 'Pending';
    final lower = raw.toLowerCase();
    if (lower == 'active') return 'Active';
    if (lower == 'disabled' || lower == 'inactive') return 'Inactive';
    if (lower == 'pending') return 'Pending';
    // If it's already like 'Active'/'Pending' keep as-is.
    return raw;
  }

  static String _toAbsoluteImageUrl(String? value) {
    if (value == null) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('data:image')) return trimmed;
    if (trimmed.startsWith('assets/')) return trimmed;
    return ApiConfig.getImageUrl(trimmed);
  }

  final String id;
  final String title;
  final String category;
  final String serviceType; // e.g., "Immigration", "Legal", "Financial", "Plumbing", "Cleaning"
  final String? provider; // Company or individual name
  final String? address;
  final String city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;
  final String? website;
  final String? description;
  final String? pricing; // e.g., "Hourly", "Fixed Rate"
  final String? priceRange; // e.g., "$50-$100/hour"
  final String? availability;
  final List<String> certifications;
  final List<String> languages;
  final String? image;
  final String status;
  final bool featured;
  final bool verified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    required this.title,
    required this.category,
    required this.serviceType,
    this.provider,
    this.address,
    required this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
    this.website,
    this.description,
    this.pricing,
    this.priceRange,
    this.availability,
    this.certifications = const [],
    this.languages = const [],
    this.image,
    this.status = 'Pending',
    this.featured = false,
    this.verified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final mediaImage = _firstImageFromMedia(json['media']);
    final explicitImage = json['image']?.toString();
    final chosenImage = (explicitImage != null && explicitImage.trim().isNotEmpty) ? explicitImage : mediaImage;

    final title = (json['title'] ?? json['serviceName'] ?? json['name'] ?? '').toString();
    final provider = (json['provider'] ?? json['providerName'])?.toString();
    final phone = (json['phone'] ?? json['contactPhone'])?.toString();

    return Service(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: title,
      category: (json['category'] ?? 'Services').toString(),
      serviceType: (json['serviceType'] ?? json['type'] ?? '').toString(),
      provider: provider,
      address: (json['address'] ?? json['area'])?.toString(),
      city: (json['city'] ?? '').toString(),
      state: json['state']?.toString(),
      zipCode: (json['zipCode'] ?? json['postalCode'])?.toString(),
      phone: phone,
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      description: json['description']?.toString(),
      pricing: json['pricing']?.toString(),
      priceRange: json['priceRange']?.toString(),
      availability: json['availability']?.toString(),
      certifications: _toStringList(json['certifications'] ?? json['certification']),
      languages: _toStringList(json['languages'] ?? json['language']),
      image: _toAbsoluteImageUrl(chosenImage),
      status: _normalizeStatus(json['status']),
      featured: json['featured'] ?? false,
      verified: json['verified'] ?? false,
      createdAt: _tryParseDateTime(json['createdAt']),
      updatedAt: _tryParseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'category': category,
      'serviceType': serviceType,
      'provider': provider,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'website': website,
      'description': description,
      'pricing': pricing,
      'priceRange': priceRange,
      'availability': availability,
      'certifications': certifications,
      'languages': languages,
      'image': image,
      'status': status,
      'featured': featured,
      'verified': verified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
