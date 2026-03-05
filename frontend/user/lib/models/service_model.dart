class Service {
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
    return Service(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Services',
      serviceType: json['serviceType'] ?? '',
      provider: json['provider'],
      address: json['address'],
      city: json['city'] ?? '',
      state: json['state'],
      zipCode: json['zipCode'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      description: json['description'],
      pricing: json['pricing'],
      priceRange: json['priceRange'],
      availability: json['availability'],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      image: json['image'],
      status: json['status'] ?? 'Pending',
      featured: json['featured'] ?? false,
      verified: json['verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
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
