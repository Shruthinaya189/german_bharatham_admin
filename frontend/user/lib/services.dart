import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/service_model.dart';
import 'saved_service_manager.dart';
import 'service_details.dart';

const String baseUrl = 'http://10.96.191.169:5000'; // Physical device on local network
// const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Service> allItems = [];
  List<Service> filteredItems = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    SavedServiceManager.instance.initialize();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/services/user'));

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
              .map((json) => Service.fromJson(json))
              .where((item) => item.status == 'Active')
              .toList();
          filteredItems = allItems;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = allItems;
      } else {
        filteredItems = allItems.where((item) {
          final titleMatch = item.title.toLowerCase().contains(query.toLowerCase());
          final typeMatch = item.serviceType.toLowerCase().contains(query.toLowerCase());
          final cityMatch = item.city.toLowerCase().contains(query.toLowerCase());
          final providerMatch = (item.provider ?? '').toLowerCase().contains(query.toLowerCase());
          return titleMatch || typeMatch || cityMatch || providerMatch;
        }).toList();
      }
    });
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
          icon: Image.asset('assets/images/left-arrow.png', height: 22, width: 22, color: Colors.black),
        ),
        title: const Text("Services", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: "Search Services",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/images/search.png', height: 20, width: 20),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4E7F6D)))
                  : filteredItems.isEmpty
                      ? const Center(child: Text('No services available'))
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return ServiceCard(item: filteredItems[index], onRefresh: _loadServices);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final Service item;
  final VoidCallback onRefresh;

  const ServiceCard({super.key, required this.item, required this.onRefresh});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late bool isSaved;
  
  @override
  void initState() {
    super.initState();
    isSaved = SavedServiceManager.instance.isSaved(widget.item.id);
  }
  
  void _toggleSave() async {
    final nowSaved = await SavedServiceManager.instance.toggle(widget.item);
    setState(() => isSaved = nowSaved);
    
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
          MaterialPageRoute(builder: (_) => ServiceDetailsPage(item: widget.item, onRefresh: widget.onRefresh)),
        );
        setState(() => isSaved = SavedServiceManager.instance.isSaved(widget.item.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60, width: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200),
              child: widget.item.image != null && widget.item.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(widget.item.image!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.business, color: Colors.grey)),
                    )
                  : const Icon(Icons.business, color: Colors.grey, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (widget.item.provider != null)
                    Text(widget.item.provider!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset('assets/images/location.png', width: 16, height: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(widget.item.city, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEFF5F1), borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.item.serviceType, style: const TextStyle(color: Colors.green, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      if (widget.item.priceRange != null)
                        Flexible(
                          child: Text(widget.item.priceRange!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 11), overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _toggleSave,
              child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? const Color(0xFF4E7F6D) : Colors.grey, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
