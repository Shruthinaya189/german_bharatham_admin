class FoodGrocery {
  final String id;
  final String title;
  final String category; // "Food"
  final String subCategory; // "Restaurant", "Grocery Store", etc.
  final String? type;
  final String location;
  final String address;
  final String city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;
  final String? website;
  final String? description;
  final String? openingHours;
  final String? priceRange;
  final double rating;
  final List<String> cuisine;
  final List<String> specialties;
  final bool deliveryAvailable;
  final bool takeoutAvailable;
  final bool dineInAvailable;
  final bool cateringAvailable;
  final String? image;
  final String status;
  final double averageRating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodGrocery({
    required this.id,
    required this.title,
    required this.category,
    required this.subCategory,
    this.type,
    required this.location,
    required this.address,
    required this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
    this.website,
    this.description,
    this.openingHours,
    this.priceRange,
    this.rating = 0.0,
    this.cuisine = const [],
    this.specialties = const [],
    this.deliveryAvailable = false,
    this.takeoutAvailable = false,
    this.dineInAvailable = false,
    this.cateringAvailable = false,
    this.image,
    this.status = 'Active',
    this.averageRating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodGrocery.fromJson(Map<String, dynamic> json) {
    return FoodGrocery(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Food',
      subCategory: json['subCategory'] ?? '',
      type: json['type'],
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'],
      zipCode: json['zipCode'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      description: json['description'],
      openingHours: json['openingHours'],
      priceRange: json['priceRange'],
      rating: (json['rating'] ?? 0).toDouble(),
      cuisine: json['cuisine'] != null ? List<String>.from(json['cuisine']) : [],
      specialties: json['specialties'] != null ? List<String>.from(json['specialties']) : [],
      deliveryAvailable: json['deliveryAvailable'] ?? false,
      takeoutAvailable: json['takeoutAvailable'] ?? false,
      dineInAvailable: json['dineInAvailable'] ?? false,
      cateringAvailable: json['cateringAvailable'] ?? false,
      image: json['image'],
      status: json['status'] ?? 'Active',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'category': category,
      'subCategory': subCategory,
      'type': type,
      'location': location,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'website': website,
      'description': description,
      'openingHours': openingHours,
      'priceRange': priceRange,
      'rating': rating,
      'cuisine': cuisine,
      'specialties': specialties,
      'deliveryAvailable': deliveryAvailable,
      'takeoutAvailable': takeoutAvailable,
      'dineInAvailable': dineInAvailable,
      'cateringAvailable': cateringAvailable,
      'image': image,
      'status': status,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get services as list
  List<String> get services {
    List<String> serviceList = [];
    if (deliveryAvailable) serviceList.add('Home Delivery');
    if (takeoutAvailable) serviceList.add('Takeout');
    // Add more based on your needs
    if (subCategory == 'Restaurant') serviceList.add('Dine-in');
    return serviceList;
  }
}
