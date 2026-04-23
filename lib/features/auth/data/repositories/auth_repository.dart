import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../models/auth_models.dart';

class AuthRepository {
  Future<User> login(String username, String password) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final loginData = LoginResponse.fromJson(jsonResponse);

      // Securely store token
      await SecureStorageHelper.saveToken(loginData.accessToken);

      return loginData.user;
    } else {
      // Handle error based on status code
      String errorMessage = 'Login failed';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['detail'] != null) {
          errorMessage = errorJson['detail'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
