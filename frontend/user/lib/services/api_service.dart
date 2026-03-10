import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_grocery_model.dart';
import '../models/rating_model.dart';

class ApiService {
  // Update this to your backend URL
  static const String baseUrl = 'http://localhost:5000';
  
  // For Android emulator use: http://10.0.2.2:5000
  // For real device, use your computer's IP address: http://192.168.x.x:5000
  // For web/iOS simulator use: http://localhost:5000
  
  /// Fetch all Food & Grocery listings
  static Future<List<FoodGrocery>> getFoodGroceryListings({
    String? search,
    String? subCategory,
    String? city,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (subCategory != null && subCategory.isNotEmpty) {
        queryParams['subCategory'] = subCategory;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }

      final uri = Uri.parse('$baseUrl/api/user/foodgrocery').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('Fetching from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
  final decoded = json.decode(response.body);

  if (decoded is Map && decoded.containsKey('data')) {
    final List<dynamic> data = decoded['data'];

    print('Received ${data.length} items');

    return data
        .map((json) => FoodGrocery.fromJson(json))
        .toList();
  } else {
    throw Exception('Unexpected API response format');
  }
} else {
        throw Exception('Failed to load listings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching food grocery listings: $e');
      throw Exception('Failed to load listings: $e');
    }
  }

  /// Fetch single Food & Grocery item by ID
  static Future<FoodGrocery> getFoodGroceryById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/foodgrocery/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FoodGrocery.fromJson(data);
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      print('Error fetching food grocery details: $e');
      throw Exception('Failed to load details: $e');
    }
  }

  /// Fetch all ratings for a restaurant
  static Future<List<Rating>> getRatings(String foodGroceryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/foodgrocery/$foodGroceryId/ratings'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Rating.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load ratings');
      }
    } catch (e) {
      print('Error fetching ratings: $e');
      throw Exception('Failed to load ratings: $e');
    }
  }

  /// Submit a rating for a restaurant
  static Future<Map<String, dynamic>> submitRating({
    required String foodGroceryId,
    required String token,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/foodgrocery/$foodGroceryId/rating'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': rating,
          'comment': comment ?? '',
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit rating');
      }
    } catch (e) {
      print('Error submitting rating: $e');
      throw Exception('Failed to submit rating: $e');
    }
  }

  /// Helper method to get base URL based on platform
  static String getBaseUrl() {
    // You can make this dynamic based on debug/release mode
    // or detect platform
    return baseUrl;
  }
}
