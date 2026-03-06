import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'food_details.dart';
import 'food_filter_page.dart';
import 'models/food_grocery_model.dart';
import 'saved_food_manager.dart';
import 'services/api_config.dart';

class FoodGroceryPage extends StatefulWidget {
  const FoodGroceryPage({super.key});

  @override
  State<FoodGroceryPage> createState() => _FoodGroceryPageState();
}

class _FoodGroceryPageState extends State<FoodGroceryPage> {
  static const String baseUrl = ApiConfig.baseUrl;
  List<FoodGrocery> allItems = [];
  List<FoodGrocery> filteredItems = [];
  bool isLoading = true;
  String searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    SavedFoodManager.instance.initialize();
  }
  
  Future<void> _loadFoodItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/foodgrocery'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> itemsList;

        // Handle both {data: [], count: n} and plain array formats
        if (data is Map && data.containsKey('data')) {
          itemsList = data['data'];
        } else if (data is List) {
          itemsList = data;
        } else {
          itemsList = [];
        }

        if (!mounted) return;
        setState(() {
          allItems = itemsList
              .map((json) => FoodGrocery.fromJson(json))
              .where((item) => item.status == 'Active')
              .toList();
          filteredItems = allItems;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading food items: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = allItems;
      } else {
        filteredItems = allItems.where((item) {
          return item.title.toLowerCase().contains(query.toLowerCase()) ||
                 item.city.toLowerCase().contains(query.toLowerCase()) ||
                 item.subCategory.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _showFilters() async {
    final result = await Navigator.push<List<FoodGrocery>>(
      context,
      MaterialPageRoute(
        builder: (context) => FoodFilterPage(allItems: allItems),
      ),
    );
    
    if (!mounted) return;
    if (result != null) {
      setState(() {
        filteredItems = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text("Food & Grocery"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ðŸ” Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: "Search Food & grocery",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showFilters,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            /// ðŸ“‹ List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF4E7F6D),
                    ))
                  : filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No food items found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return FoodCard(
                              item: filteredItems[index],
                              onRefresh: _loadFoodItems,
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}

class FoodCard extends StatefulWidget {
  final FoodGrocery item;
  final VoidCallback onRefresh;

  const FoodCard({
    super.key,
    required this.item,
    required this.onRefresh,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  late bool isSaved;
  
  @override
  void initState() {
    super.initState();
    isSaved = SavedFoodManager.instance.isSaved(widget.item.id);
  }
  
  void _toggleSave() async {
    final nowSaved = await SavedFoodManager.instance.toggle(widget.item);
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailPage(
              item: widget.item,
              onRefresh: widget.onRefresh,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.item.image != null && widget.item.image!.isNotEmpty
                  ? (widget.item.image!.startsWith('http')
                      ? Image.network(
                          widget.item.image!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholderImage(),
                        )
                      : Image.asset(
                          widget.item.image!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholderImage(),
                        ))
                  : _placeholderImage(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _toggleSave,
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: isSaved ? const Color(0xFF4E7F6D) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.item.city}, ${widget.item.state ?? 'Bavaria'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.item.averageRating > 0
                            ? widget.item.averageRating.toStringAsFixed(1)
                            : '4.5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '1.2km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFE8F5E9),
      child: const Icon(
        Icons.restaurant,
        size: 36,
        color: Color(0xFF4E7F6D),
      ),
    );
  }
}
