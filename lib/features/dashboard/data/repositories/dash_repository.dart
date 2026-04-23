import 'dart:convert';
import 'package:dtrs_survey/core/network/api_constants.dart';
import 'package:http/http.dart' as http;
import '../models/structure_model.dart';

class DashboardRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> getDashboardData(
    String phone,
    String token,
  ) async {
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    final responses = await Future.wait([
      http.get(
        Uri.parse("$baseUrl/ae/structure-count/$phone"),
        headers: headers,
      ),
      http.get(Uri.parse("$baseUrl/ae/pending-count/$phone"), headers: headers),
      http.get(
        Uri.parse("$baseUrl/ae/completed-count/$phone"),
        headers: headers,
      ),
    ]);
    if (responses.any((res) => res.statusCode != 200)) {
      throw Exception("Failed to load dashboard data");
    }

    final totalData = jsonDecode(responses[0].body);
    final pendingData = jsonDecode(responses[1].body);
    final completedData = jsonDecode(responses[2].body);

    return {
      "total": totalData["structure_count"],
      "pending": pendingData["pending_count"],
      "completed": completedData["completed_count"],
    };
  }

  Future<StructuresResponse> getStructures(
    String title,
    String phone,
    String token, {
    int page = 1,
    int pageSize = 100,
      String? search,
  }) async {
    var url =
        '$baseUrl/ae/structures?ae_phno=$phone&page=$page&page_size=$pageSize';
    if (title.toLowerCase().contains('pending')) {
      url += '&status=pending';
    } else if (title.toLowerCase().contains('completed')) {
      url += '&status=completed';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return StructuresResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load structures');
    }
  }
}
