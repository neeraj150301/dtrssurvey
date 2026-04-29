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

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.sendOtpEndpoint}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone_number": phone}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? "Failed to send OTP");
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.verifyOtpEndpoint}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone_number": phone, "otp": otp}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? "Failed to send OTP");
    }
  }

    Future<Map<String, dynamic>> resetPassword(String phone, String newPassword, String resetToken) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.resetPasswordEndpoint}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone_number": phone, "new_password": newPassword, "reset_token": resetToken}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? "Failed to send OTP");
    }
  }

    Future<String> logout(String token) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token",},
      
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['message'] ?? "Failed to send OTP");
    }
  }


}
