import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../models/substation_feeder_model.dart';

class SurveyRepository {
  Future<List<Substation>> getSubstations(String sectionCode) async {
    final token = await SecureStorageHelper.getToken();

    final url = Uri.parse('${ApiConstants.baseUrl}/substations/$sectionCode');
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['substations'] as List)
          .map((e) => Substation.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load substations');
    }
  }

  Future<List<Feeder>> getFeeders(String substationCode) async {
    final token = await SecureStorageHelper.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/feeders/$substationCode');
    
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['feeders'] as List)
          .map((e) => Feeder.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load feeders');
    }
  }
}
