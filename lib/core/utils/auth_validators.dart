class AuthValidator {
  static String? validatePhone(String value) {
    if (value.trim().isEmpty) {
      return "Mobile number is required";
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Enter valid 10 digit mobile number";
    }

    return null;
  }

  static String? validateOtp(String value) {
    if (value.trim().isEmpty) {
      return "OTP is required";
    }

    if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
      return "Enter valid 4 digit OTP";
    }

    return null;
  }

  static String? validatePassword(String value) {
    if (value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return "Password must contain at least one number";
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]',
    ).hasMatch(value)) {
      return "Password must contain at least one special character";
    }

    return null;
  }

  static String? validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.trim().isEmpty) {
      return "Confirm password is required";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    return null;
  }
}