import 'package:dtrs_survey/features/dashboard/data/models/profile_model.dart';

class ProfileState {
  final bool isLoading;
  final Profile? profile;
  final String? error;
  final bool isCached;

  final bool isUpdatingPassword;
  final bool isUpdateSuccess;
  final String? updateError;

  ProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
    this.isCached = false,
        this.isUpdatingPassword = false,
    this.isUpdateSuccess = false,
    this.updateError,
  });

  ProfileState copyWith({
    bool? isLoading,
    Profile? profile,
    String? error,
    bool? isCached,
        bool? isUpdatingPassword,
    bool? isUpdateSuccess,
    String? updateError,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      isCached: isCached ?? this.isCached,
            isUpdatingPassword:
          isUpdatingPassword ?? this.isUpdatingPassword,
      isUpdateSuccess:
          isUpdateSuccess ?? this.isUpdateSuccess,
      updateError: updateError,
    );
  }
}