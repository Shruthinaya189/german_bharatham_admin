import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'saved.dart';
import 'profile.dart';
import 'job_details.dart';
import 'accommodation_details.dart';
import 'food_details.dart';
import 'accommodation.dart';
import 'models/food_grocery_model.dart';
import 'models/job_model.dart';
import 'services/job_service.dart';
import 'services/api_config.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedTab = 0;
  int bottomIndex = 1;
  String _searchQuery = '';
  bool _loading = true;

  List<Job> _allJobs = [];
  List<Accommodation> _allAccommodations = [];
  List<FoodGrocery> _allFood = [];

  final tabs = ['All', 'Accommodation', 'Food', 'Jobs', 'Services'];

  @override
  void initState() {
    super.initState();
    _loadAllContent();
  }

  Future<void> _loadAllContent() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final jobsFuture = JobService.fetchAllJobs();
      final accommodationFuture = _fetchAccommodations();
      final foodFuture = _fetchFood();

      final results = await Future.wait([
        jobsFuture,
        accommodationFuture,
        foodFuture,
      ]);

      if (!mounted) return;
      setState(() {
        _allJobs = results[0] as List<Job>;
        _allAccommodations = results[1] as List<Accommodation>;
        _allFood = results[2] as List<FoodGrocery>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<List<Accommodation>> _fetchAccommodations() async {
    final response = await http.get(Uri.parse(ApiConfig.accommodationEndpoint));
    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? (decoded['data'] ?? []) : []);

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return Accommodation.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<Accommodation>()
        .toList();
  }

  Future<List<FoodGrocery>> _fetchFood() async {
    final response = await http.get(Uri.parse(ApiConfig.foodEndpoint));
    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? (decoded['data'] ?? []) : []);

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return FoodGrocery.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<FoodGrocery>()
        .where((f) => f.status == 'Active')
        .toList();
  }

  List<Job> _filteredJobs() {
    final sorted = List<Job>.from(_allJobs)
      ..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    if (_searchQuery.trim().isEmpty) return sorted.take(3).toList();
    final q = _searchQuery.toLowerCase();
    return sorted
        .where((j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q) ||
            j.location.toLowerCase().contains(q))
        .toList();
  }

  List<Accommodation> _filteredAccommodations() {
    final sorted = List<Accommodation>.from(_allAccommodations)
      ..sort((a, b) => b.id.compareTo(a.id));
    if (_searchQuery.trim().isEmpty) return sorted.take(3).toList();
    final q = _searchQuery.toLowerCase();
    return sorted
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.location.toLowerCase().contains(q) ||
            a.propertyType.toLowerCase().contains(q))
        .toList();
  }

  List<FoodGrocery> _filteredFood() {
    final sorted = List<FoodGrocery>.from(_allFood)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_searchQuery.trim().isEmpty) return sorted.take(3).toList();
    final q = _searchQuery.toLowerCase();
    return sorted
        .where((f) =>
            f.title.toLowerCase().contains(q) ||
            f.city.toLowerCase().contains(q) ||
            f.subCategory.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          title: const Text('Search'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: null,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4E7F6D)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBar(),
                    const SizedBox(height: 14),
                    _categoryTabs(),
                    const SizedBox(height: 20),
                    if (selectedTab == 0 || selectedTab == 1) ...[
                      _sectionHeader('Recent Accommodations'),
                      _accommodationResultsSection(),
                      const SizedBox(height: 18),
                    ],
                    if (selectedTab == 0 || selectedTab == 2) ...[
                      _sectionHeader('Recent Food & Grocery'),
                      _foodResultsSection(),
                      const SizedBox(height: 18),
                    ],
                    if (selectedTab == 0 || selectedTab == 3) ...[
                      _sectionHeader('Recent Jobs'),
                      _jobResultsSection(),
                      const SizedBox(height: 18),
                    ],
                    if (selectedTab == 4)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Open Services from Home to browse all service listings.'),
                      ),
                  ],
                ),
              ),
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search accommodation, food, jobs...',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/search.png', width: 20),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _categoryTabs() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => selectedTab = index),
            child: _chip(tabs[index], selectedTab == index),
          );
        },
      ),
    );
  }

  Widget _chip(String text, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF4E7F6D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _accommodationResultsSection() {
    final items = _filteredAccommodations();
    if (items.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No accommodation found'));

    return Column(
      children: items.map((item) {
        return _commonCard(
          image: item.image,
          title: item.title,
          subtitle: item.location,
          trailing: 'EUR ${item.price}/month',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AccommodationDetailPage(item: item)),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _foodResultsSection() {
    final items = _filteredFood();
    if (items.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No food listings found'));

    return Column(
      children: items.map((item) {
        return _commonCard(
          image: item.image ?? '',
          title: item.title,
          subtitle: item.city,
          trailing: item.priceRange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FoodDetailPage(item: item, onRefresh: _loadAllContent),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _jobResultsSection() {
    final items = _filteredJobs();
    if (items.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No jobs found'));

    return Column(
      children: items.map((job) {
        return _commonCard(
          image: job.companyLogo ?? '',
          title: job.title,
          subtitle: job.location,
          trailing: job.salary == null ? null : 'EUR ${job.salary}',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailsPage(job: job)),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _commonCard({
    required String image,
    required String title,
    required String subtitle,
    String? trailing,
    required VoidCallback onTap,
  }) {
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (trailing != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      trailing,
                      style: const TextStyle(color: Color(0xFF4E7F6D), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImage(),
      );
    }

    if (src.startsWith('/')) {
      final url = '${ApiConfig.baseUrl}$src';
      return Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImage(),
      );
    }

    if (src.isNotEmpty && src.startsWith('assets/')) {
      return Image.asset(
        src,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImage(),
      );
    }

    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFFEAF2EE),
      child: const Icon(Icons.image_outlined, color: Color(0xFF4E7F6D), size: 20),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          }
          if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SavedPage()));
          }
          if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: Image.asset('assets/images/home.png', height: 24), label: 'Home'),
          BottomNavigationBarItem(icon: Image.asset('assets/images/search.png', height: 24), label: 'Search'),
          BottomNavigationBarItem(icon: Image.asset('assets/images/bookmark.png', height: 24), label: 'Saved'),
          BottomNavigationBarItem(icon: Image.asset('assets/images/profile.png', height: 24), label: 'Profile'),
        ],
      ),
    );
  }
}
