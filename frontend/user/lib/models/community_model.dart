class CommunityPost {
  final String id;
  final String title;
  final String description;
  final String category;
  final String author;
  final String date;

  final List<String> keyPoints;
  final String officialWebsites;
  final String communityDiscussions;

  CommunityPost({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.author,
    required this.date,
    required this.keyPoints,
    required this.officialWebsites,
    required this.communityDiscussions,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      author: json['author'] ?? '',
      date: json['date'] ?? '',

      keyPoints: json['keyPoints'] != null
          ? List<String>.from(json['keyPoints'])
          : [],

      officialWebsites: json['officialWebsites'] ?? '',
      communityDiscussions: json['communityDiscussions'] ?? '',
    );
  }
}