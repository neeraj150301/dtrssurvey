import 'dart:convert';
import 'package:dtrs_survey/core/network/api_constants.dart';
import 'package:dtrs_survey/features/dashboard/data/models/profile_model.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/profile_bloc/profile_event.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/profile_bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  Profile? _cache;

  ProfileBloc() : super(ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdatePassword>(_onUpdatePassword);
  }

  Future<void> _onUpdatePassword(
    UpdatePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdatingPassword: true,
        isUpdateSuccess: false,
        updateError: null,
      ),
    );
    try {
      final res = await http.put(
        Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.changePasswordEndpoint}",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobile_number": event.mobile,
          "old_password": event.currentPassword,
          "new_password": event.newPassword,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['message'] == 'Password updated successfully') {
        emit(state.copyWith(isUpdatingPassword: false, isUpdateSuccess: true));
      } else {
        emit(
          state.copyWith(
            isUpdatingPassword: false,
            updateError: data['detail'] ?? "Failed",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(isUpdatingPassword: false, updateError: e.toString()),
      );
    }
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // RETURN CACHE FIRST
    if (_cache != null) {
      emit(state.copyWith(profile: _cache, isCached: true));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final res = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.arDetailsEndpoint}${event.mobile}",
        ),
      );

      final data = jsonDecode(res.body);
      final profile = Profile.fromJson(data);

      _cache = profile;

      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
