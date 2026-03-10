import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/job_model.dart';
import 'saved_job_manager.dart';
import 'job_details.dart';
import 'jobs_filter_page.dart';
import 'services/api_config.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  List<Job> allItems = [];
  List<Job> filterItems = [];
  List<Job> filteredItems = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    SavedJobManager.instance.initialize();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.jobsEndpoint),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> itemsList;
        if (data is Map && data.containsKey('data')) {
          itemsList = data['data'];
        } else if (data is List) {
          itemsList = data;
        } else {
          itemsList = [];
        }

        setState(() {
          allItems = itemsList
              .map((json) => Job.fromJson(json))
              .where((item) => item.status == 'Active')
              .toList();
          filterItems = allItems;
          _applySearch();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading jobs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      _applySearch();
    });
  }

  void _applySearch() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      filteredItems = List.from(filterItems);
      return;
    }

    filteredItems = filterItems.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query);
      final companyMatch = item.company.toLowerCase().contains(query);
      final cityMatch = item.city.toLowerCase().contains(query);
      final jobTypeMatch = item.jobType.toLowerCase().contains(query);
      return titleMatch || companyMatch || cityMatch || jobTypeMatch;
    }).toList();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<List<Job>>(
      context,
      MaterialPageRoute(
        builder: (_) => JobsFilterPage(allItems: allItems),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        filterItems = result;
        _applySearch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
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
        title: const Text(
          "Jobs",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search + filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: "Search Jobs",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/search.png',
                          height: 20,
                          width: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
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
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Image.asset(
                      'assets/images/sort.png',
                      height: 22,
                      width: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 📋 Job list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4E7F6D)))
                  : filteredItems.isEmpty
                      ? const Center(child: Text('No jobs available'))
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return JobCard(
                              item: filteredItems[index],
                              onRefresh: _loadJobs,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatefulWidget {
  final Job item;
  final VoidCallback onRefresh;

  const JobCard({
    super.key,
    required this.item,
    required this.onRefresh,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late bool isSaved;
  
  @override
  void initState() {
    super.initState();
    isSaved = SavedJobManager.instance.isSaved(widget.item.id);
  }
  
  void _toggleSave() async {
    final nowSaved = await SavedJobManager.instance.toggle(widget.item);
    if (!mounted) return;
    setState(() {
      isSaved = nowSaved;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF4E7F6D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsPage(
              item: widget.item,
              onRefresh: widget.onRefresh,
            ),
          ),
        );
        if (!mounted) return;
        setState(() {
          isSaved = SavedJobManager.instance.isSaved(widget.item.id);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Company Logo
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/google.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            /// Job details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.company,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/location.png',
                        width: 16,
                        height: 16,
                        color: Colors.grey,
                        errorBuilder: (_, __, ___) => const SizedBox(width: 16, height: 16),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.item.city,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF5F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.item.jobType,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (widget.item.salary != null)
                        Flexible(
                          child: Text(
                            widget.item.salary!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            /// Bookmark icon
            InkWell(
              onTap: _toggleSave,
              child: Image.asset(
                'assets/images/bookmark.png',
                width: 22,
                height: 22,
                color: isSaved ? const Color(0xFF4E7F6D) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
