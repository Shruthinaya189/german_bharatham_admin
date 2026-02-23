import 'package:flutter/material.dart';
import 'guide_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List guides = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadCachedThenFetch();
  }

  Future<void> _loadCachedThenFetch() async {
    // First try to load cached guides so user sees something immediately
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_guides');
    if (cached != null) {
      try {
        final list = json.decode(cached);
        setState(() {
          guides = list;
          isLoading = false;
          errorMessage = "";
        });
      } catch (_) {}
    }

    // Then attempt network fetch to refresh data (will update UI and cache)
    await fetchGuides();
  }

  Future<void> fetchGuides() async {
    try {
      // Backend runs on port 5000 (see backend/.env). Include port so
      // requests reach the Express server instead of defaulting to port 80.
      final response = await http.get(
        Uri.parse("http://10.166.137.12:5000/api/community"),
      );

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // cache response
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_guides', response.body);
        } catch (_) {}

        setState(() {
          guides = data;
          isLoading = false;
          errorMessage = "";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load guides (Status: ${response.statusCode})";
        });
        print("Failed to load guides");
      }
    } catch (e) {
      // On error, keep any cached data already shown; only show error
      // if there is no cached data available.
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_guides');
      setState(() {
        isLoading = false;
        if ((guides.isEmpty) && (cached == null)) {
          errorMessage = "Error: ${e.toString()}";
        } else {
          errorMessage = ""; // show cached data silently
        }
      });
      print("Error: $e");
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
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
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
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GuideDetailsPage(guide: guides[index]),
                                      ),
                                    );
                                  },
                                  child: _communityCard(guides[index]),
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
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/search.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                hintText: "Search Services",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
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
        )
      ],
    );
  }

  Widget _communityCard(dynamic guide) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  guide["title"] ?? "",
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/bookmark.png',
                height: 20,
                width: 20,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${guide["author"] ?? ""} • ${guide["date"] ?? ""}",
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
                child: const Text(
                  "Guide",
                  style: TextStyle(
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