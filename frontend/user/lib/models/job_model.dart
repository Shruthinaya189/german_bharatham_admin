import '../services/api_config.dart';

class Job {
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
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return [];
      return trimmed
          .split(RegExp(r'[,;\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return false;
  }

  static String _normalizeStatus(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return 'Pending';
    final lower = raw.toLowerCase();
    if (lower == 'active') return 'Active';
    if (lower == 'disabled' || lower == 'inactive') return 'Inactive';
    if (lower == 'pending') return 'Pending';
    return raw;
  }

  static String? _toAbsoluteImageUrl(dynamic value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    if (trimmed.startsWith('data:image')) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    if (trimmed.startsWith('assets/')) return trimmed;
    return ApiConfig.getImageUrl(trimmed);
  }

  final String id;
  final String title;
  final String category;
  final String company;
  final String? companyLogo;
  final String jobType; // Full-time, Part-time, Contract, Internship
  final String location;
  final String city;
  final String? state;
  final bool remote;
  final String? salary;
  final String? email;
  final String? website;
  final String? phone;
  final String? description;
  final List<String> requirements;
  final List<String> responsibilities;
  final List<String> benefits;
  final String? experience; // e.g., "2-5 years"
  final String? education;
  final String? applyUrl;
  final String status;
  final bool featured;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Job({
    required this.id,
    required this.title,
    required this.category,
    required this.company,
    this.companyLogo,
    required this.jobType,
    required this.location,
    required this.city,
    this.state,
    required this.remote,
    this.salary,
    this.email,
    this.website,
    this.phone,
    this.description,
    this.requirements = const [],
    this.responsibilities = const [],
    this.benefits = const [],
    this.experience,
    this.education,
    this.applyUrl,
    this.status = 'Pending',
    this.featured = false,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: json['category'] ?? 'Job',
      // Handle both 'company' (new schema) and 'companyName' (old/admin schema)
      company: (json['company'] ?? json['companyName'] ?? '').toString(),
      companyLogo: _toAbsoluteImageUrl(json['companyLogo'] ?? json['logo'] ?? json['image']),
      jobType: (json['jobType'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: json['state']?.toString(),
      remote: _toBool(json['remote']),
      salary: json['salary']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
      requirements: _toStringList(json['requirements']),
      responsibilities: _toStringList(json['responsibilities']),
      benefits: _toStringList(json['benefits']),
      experience: json['experience']?.toString(),
      education: json['education']?.toString(),
      applyUrl: json['applyUrl']?.toString(),
      status: _normalizeStatus(json['status'] ?? 'Pending'),
      featured: _toBool(json['featured']),
      expiresAt: _tryParseDateTime(json['expiresAt']),
      createdAt: _tryParseDateTime(json['createdAt']),
      updatedAt: _tryParseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'category': category,
      'company': company,
      'jobType': jobType,
      'location': location,
      'city': city,
      'state': state,
      'remote': remote,
      'salary': salary,
      'email': email,
      'website': website,
      'phone': phone,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'experience': experience,
      'education': education,
      'applyUrl': applyUrl,
      'status': status,
      'featured': featured,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
