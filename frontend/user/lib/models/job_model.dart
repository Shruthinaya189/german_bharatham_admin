class Job {
  final String id;
  final String title;
  final String category;
  final String company;
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
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Job',
      company: json['company'] ?? '',
      jobType: json['jobType'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'],
      remote: json['remote'] ?? false,
      salary: json['salary'],
      email: json['email'],
      website: json['website'],
      phone: json['phone'],
      description: json['description'],
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      responsibilities: json['responsibilities'] != null
          ? List<String>.from(json['responsibilities'])
          : [],
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],
      experience: json['experience'],
      education: json['education'],
      applyUrl: json['applyUrl'],
      status: json['status'] ?? 'Pending',
      featured: json['featured'] ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
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
