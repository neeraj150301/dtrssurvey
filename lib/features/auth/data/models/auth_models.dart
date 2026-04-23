class User {
  final int id;
  final String username;
  final String phoneNumber;
  final String fullName;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
