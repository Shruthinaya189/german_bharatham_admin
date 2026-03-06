import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';
import 'api_config.dart';

class JobService {
  /// Fetch all active jobs from the backend
  static Future<List<Job>> fetchAllJobs() async {
    try {
      print('=== JobService.fetchAllJobs ===');
      print('Endpoint: ${ApiConfig.jobsEndpoint}');
      
      final response = await http.get(
        Uri.parse(ApiConfig.jobsEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Request timeout when fetching jobs');
          throw Exception('Request timeout. Please check your connection and backend server.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Successfully fetched ${data.length} jobs');
        return data.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching jobs: $e');
      print('Make sure backend is reachable at ${ApiConfig.baseUrl}');
      print('Check that /api/jobs endpoint is accessible from device');
      throw Exception('Failed to load jobs: $e');
    }
  }

  /// Fetch single job by ID
  static Future<Job> fetchJobById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.jobsEndpoint}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Job.fromJson(data);
      } else {
        throw Exception('Failed to load job details');
      }
    } catch (e) {
      print('Error fetching job details: $e');
      throw Exception('Failed to load job details: $e');
    }
  }

  /// Search jobs with query
  static Future<List<Job>> searchJobs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.jobsEndpoint}/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search jobs');
      }
    } catch (e) {
      print('Error searching jobs: $e');
      throw Exception('Failed to search jobs: $e');
    }
  }
}
