abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String mobile;
  LoadProfile(this.mobile);
}

class UpdatePassword extends ProfileEvent {
  final String mobile;
  final String currentPassword;
  final String newPassword;
  UpdatePassword({
    required this.mobile,
    required this.currentPassword,
    required this.newPassword,
  });
}

class ClearProfile extends ProfileEvent {}
