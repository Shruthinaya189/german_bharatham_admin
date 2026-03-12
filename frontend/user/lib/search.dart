import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'accommodation.dart';
import 'accommodation_details.dart';
import 'food_grocery.dart';
import 'home.dart';
import 'jobs.dart';
import 'models/food_grocery_model.dart';
import 'models/job_model.dart';
import 'models/service_model.dart';
import 'profile.dart';
import 'saved.dart';
import 'saved_manager.dart';
import 'services.dart';
import 'services/api_config.dart';
import 'saved_food_manager.dart';
import 'saved_job_manager.dart';
import 'saved_service_manager.dart';
import 'user_profiles_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedTab = 0;
  int bottomIndex = 1;

  bool isLoading = true;
  String? errorMessage;

  String searchQuery = '';

  List<Accommodation> _allAccommodations = [];
  List<Job> _allJobs = [];
  List<FoodGrocery> _allFood = [];
  List<Service> _allServices = [];

  final tabs = [
    "All",
    "My Accommodations",
    "My Food & Grocery",
    "My Jobs",
    "My Services",
  ];

  String _searchHint() {
    switch (selectedTab) {
      case 1:
        return "Search my accommodations...";
      case 2:
        return "Search my food & grocery...";
      case 3:
        return "Search my jobs...";
      case 4:
        return "Search my services...";
      default:
        return "Search anything...";
    }
  }

  @override
  void initState() {
    super.initState();
    _initSaved();
    _loadAll();
  }

  Future<void> _initSaved() async {
    await SavedJobManager.instance.initialize();
    await SavedFoodManager.instance.initialize();
    await SavedServiceManager.instance.initialize();
  }

  Future<void> _loadAll() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.wait([
        _loadAccommodations(),
        _loadJobs(),
        _loadFood(),
        _loadServices(),
      ]);
    } catch (e) {
      errorMessage = 'Failed to load data';
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadAccommodations() async {
    final response = await http.get(Uri.parse(ApiConfig.accommodationEndpoint));
    if (response.statusCode != 200) return;
    final decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] ?? []) as List;
    final items = list
        .whereType<Map<String, dynamic>>()
        .map(Accommodation.fromJson)
        .toList();

    for (final item in items) {
      item.isSaved = SavedManager.instance.isSaved(item.id);
    }

    _allAccommodations = items;
  }

  Future<void> _loadJobs() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/jobs/user'));
    if (response.statusCode != 200) return;
    final decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] ?? []) as List;
    _allJobs = list
        .whereType<Map<String, dynamic>>()
        .map(Job.fromJson)
        .where((j) => j.status.toLowerCase() == 'active')
        .toList();
  }

  Future<void> _loadFood() async {
    final response = await http.get(Uri.parse(ApiConfig.foodEndpoint));
    if (response.statusCode != 200) return;
    final decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] ?? []) as List;
    _allFood = list
        .whereType<Map<String, dynamic>>()
        .map(FoodGrocery.fromJson)
        .where((f) => f.status == 'Active')
        .toList();
  }

  Future<void> _loadServices() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/services/user'));
    if (response.statusCode != 200) return;
    final decoded = jsonDecode(response.body);
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] ?? []) as List;
    _allServices = list
        .whereType<Map<String, dynamic>>()
        .map(Service.fromJson)
        .where((s) => s.status == 'Active')
        .toList();
  }

  List<Accommodation> get _accommodationsFiltered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List.from(_allAccommodations);
    return _allAccommodations.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.propertyType.toLowerCase().contains(q);
    }).toList();
  }

  List<Job> get _jobsFiltered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List.from(_allJobs);
    return _allJobs.where((j) {
      return j.title.toLowerCase().contains(q) ||
          j.company.toLowerCase().contains(q) ||
          j.city.toLowerCase().contains(q) ||
          j.jobType.toLowerCase().contains(q);
    }).toList();
  }

  List<FoodGrocery> get _foodFiltered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List.from(_allFood);
    return _allFood.where((f) {
      return f.title.toLowerCase().contains(q) ||
          f.city.toLowerCase().contains(q) ||
          f.subCategory.toLowerCase().contains(q);
    }).toList();
  }

  List<Service> get _servicesFiltered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List.from(_allServices);
    return _allServices.where((s) {
      final provider = (s.provider ?? '').toLowerCase();
      return s.title.toLowerCase().contains(q) ||
          s.serviceType.toLowerCase().contains(q) ||
          s.city.toLowerCase().contains(q) ||
          provider.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
  title: const Text("Search"),
  centerTitle: true,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,

  automaticallyImplyLeading: false,
  leading: null,
),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            const SizedBox(height: 14),
            _categoryTabs(),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4E7F6D),
                      ),
                    )
                  : (errorMessage != null)
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : _resultsBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    ),
    );
  }

  /// 🔍 SEARCH BAR
  Widget _searchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: _searchHint(),
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

  /// 🔘 CATEGORY TABS
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

  Widget _sectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          InkWell(
            onTap: onViewAll,
            child: const Text(
              'View all',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsBody() {
    if (selectedTab == 0) {
      return _allResults();
    }

    if (selectedTab == 1) {
      final list = _accommodationsFiltered;
      return list.isEmpty
          ? const Center(child: Text('No accommodations found'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final item = list[i];
                return AccommodationCard(
                  accommodation: item,
                  onBookmarkTap: () {
                    setState(() {
                      SavedManager.instance.toggle(item);
                      item.isSaved = SavedManager.instance.isSaved(item.id);
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccommodationDetailPage(item: item),
                      ),
                    );
                  },
                );
              },
            );
    }

    if (selectedTab == 2) {
      final list = _foodFiltered;
      return list.isEmpty
          ? const Center(child: Text('No food & grocery found'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                return FoodCard(item: list[i], onRefresh: () => _loadAll());
              },
            );
    }

    if (selectedTab == 3) {
      final list = _jobsFiltered;
      return list.isEmpty
          ? const Center(child: Text('No jobs found'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                return JobCard(item: list[i], onRefresh: () => _loadAll());
              },
            );
    }

    final list = _servicesFiltered;
    return list.isEmpty
        ? const Center(child: Text('No services found'))
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              return ServiceCard(item: list[i], onRefresh: () => _loadAll());
            },
          );
  }

  Widget _allResults() {
    final accommodations = _accommodationsFiltered;
    final food = _foodFiltered;
    final jobs = _jobsFiltered;
    final services = _servicesFiltered;

    final nothingFound =
        accommodations.isEmpty && food.isEmpty && jobs.isEmpty && services.isEmpty;
    if (nothingFound) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      children: [
        if (accommodations.isNotEmpty) ...[
          _sectionHeader('My Accommodations', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AccommodationPage()));
          }),
          ...accommodations.take(2).map(
                (item) => AccommodationCard(
                  accommodation: item,
                  onBookmarkTap: () {
                    setState(() {
                      SavedManager.instance.toggle(item);
                      item.isSaved = SavedManager.instance.isSaved(item.id);
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccommodationDetailPage(item: item),
                      ),
                    );
                  },
                ),
              ),
          const SizedBox(height: 18),
        ],
        if (jobs.isNotEmpty) ...[
          _sectionHeader('My Jobs', () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const JobsPage()));
          }),
          ...jobs.take(2)
              .map((item) => JobCard(item: item, onRefresh: () => _loadAll())),
          const SizedBox(height: 18),
        ],
        if (food.isNotEmpty) ...[
          _sectionHeader('My Food & Grocery', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FoodGroceryPage()));
          }),
          ...food.take(2)
              .map((item) => FoodCard(item: item, onRefresh: () => _loadAll())),
          const SizedBox(height: 18),
        ],
        if (services.isNotEmpty) ...[
          _sectionHeader('My Services', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ServicesPage()));
          }),
          ...services.take(2)
              .map((item) => ServiceCard(item: item, onRefresh: () => _loadAll())),
        ],
      ],
    );
  }

  /// 🔻 CUSTOM BOTTOM NAV
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
        selectedItemColor: const Color(0xFF4E7F6D),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserProfilesPage()),
            );
          }
          if (index == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const SavedPage()));
          }
          if (index == 4) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home.png',
              height: 24,
              color: bottomIndex == 0 ? const Color(0xFF4E7F6D) : Colors.grey,
              errorBuilder: (_, __, ___) => Icon(
                Icons.home,
                size: 24,
                color: bottomIndex == 0 ? const Color(0xFF4E7F6D) : Colors.grey,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/search.png',
              height: 24,
              color: bottomIndex == 1 ? const Color(0xFF4E7F6D) : Colors.grey,
              errorBuilder: (_, __, ___) => Icon(
                Icons.search,
                size: 24,
                color: bottomIndex == 1 ? const Color(0xFF4E7F6D) : Colors.grey,
              ),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/social.png',
              height: 24,
              color: bottomIndex == 2 ? const Color(0xFF4E7F6D) : Colors.grey,
              errorBuilder: (_, __, ___) => Icon(
                Icons.people,
                size: 24,
                color: bottomIndex == 2 ? const Color(0xFF4E7F6D) : Colors.grey,
              ),
            ),
            label: 'Profiles',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/bookmark.png',
              height: 24,
              color: bottomIndex == 3 ? const Color(0xFF4E7F6D) : Colors.grey,
              errorBuilder: (_, __, ___) => Icon(
                Icons.bookmark,
                size: 24,
                color: bottomIndex == 3 ? const Color(0xFF4E7F6D) : Colors.grey,
              ),
            ),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/profile.png',
              height: 24,
              color: bottomIndex == 4 ? const Color(0xFF4E7F6D) : Colors.grey,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person,
                size: 24,
                color: bottomIndex == 4 ? const Color(0xFF4E7F6D) : Colors.grey,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
