class Rating {
  final String id;
  final String foodGroceryId;
  final String userId;
  final String? userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.foodGroceryId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      foodGroceryId: json['foodGroceryId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'foodGroceryId': foodGroceryId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
