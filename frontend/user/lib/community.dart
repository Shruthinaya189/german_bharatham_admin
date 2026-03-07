import 'package:flutter/material.dart';
import 'guide_details.dart';
import 'saved_guides_manager.dart';
import 'community_filter_page.dart';
import 'models/community_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<CommunityPost> guides = [];
  List<CommunityPost> allGuides = [];
  List<CommunityPost> filterGuides = [];
  bool isLoading = true;
  String errorMessage = "";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedGuides();
    _loadCachedThenFetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedGuides() async {
    await SavedGuidesManager.instance.getSavedItems();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openFilter() async {
    final filteredPosts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityFilterPage(allPosts: allGuides),
      ),
    );

    if (filteredPosts != null && filteredPosts is List<CommunityPost>) {
      setState(() {
        filterGuides = filteredPosts;
        _applySearch();
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applySearch();
    });
  }

  void _applySearch() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      guides = List.from(filterGuides);
      return;
    }

    guides = filterGuides.where((post) {
      return post.title.toLowerCase().contains(query) ||
          post.description.toLowerCase().contains(query) ||
          post.category.toLowerCase().contains(query) ||
          post.author.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _loadCachedThenFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_guides');

    if (cached != null) {
      try {
        final List list = json.decode(cached);

        guides = list.map((e) => CommunityPost.fromJson(e)).toList();
        allGuides = guides;
        filterGuides = guides;
        _applySearch();

        setState(() {
          isLoading = false;
        });
      } catch (_) {}
    }

    await fetchGuides();
  }

  Future<void> fetchGuides() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.166.137.12:5000/api/community"),
      );

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        final fetchedGuides =
            jsonData.map((e) => CommunityPost.fromJson(e)).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_guides', response.body);

        if (!mounted) return;

        setState(() {
          allGuides = fetchedGuides;
          filterGuides = fetchedGuides;
          _applySearch();
          isLoading = false;
          errorMessage = "";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load guides";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;

        if (guides.isEmpty) {
          errorMessage = "Network error";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            height: 22,
            width: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Community",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : guides.isEmpty
                          ? const Center(
                              child: Text("No community posts found"),
                            )
                          : ListView.builder(
                              itemCount: guides.length,
                              itemBuilder: (context, index) {
                                final guide = guides[index];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GuideDetailsPage(guide: guide),
                                      ),
                                    );
                                  },
                                  child: _communityCard(guide),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/search.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                hintText: "Search Guides",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _openFilter,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Image.asset(
              'assets/images/sort.png',
              height: 22,
              width: 22,
            ),
          ),
        )
      ],
    );
  }

  Widget _communityCard(CommunityPost guide) {
    final isSaved = SavedGuidesManager.instance.isSavedSync(guide.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  guide.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final wasSaved =
                      SavedGuidesManager.instance.isSavedSync(guide.id);
                  await SavedGuidesManager.instance.toggle(guide);

                  if (!mounted) return;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasSaved ? 'Removed from saved' : 'Saved',
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/bookmark.png',
                  width: 22,
                  height: 22,
                  color: isSaved ? Colors.black : Colors.grey,
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${guide.author} • ${guide.date}",
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F2EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  guide.category,
                  style: const TextStyle(
                    color: Color(0xFF3B8F6A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/right-arrow.png',
                height: 16,
                width: 16,
              ),
            ],
          )
        ],
      ),
    );
  }
}