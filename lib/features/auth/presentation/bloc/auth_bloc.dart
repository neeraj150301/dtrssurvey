import 'package:dtrs_survey/core/storage/secure_storage_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<ResetPasswordRequested>(_onResetPassword);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (event.identifier.isEmpty || event.password.isEmpty) {
        emit(const AuthFailure(error: 'Please enter valid credentials'));
        return;
      }
      final user = await _authRepository.login(
        event.identifier,
        event.password,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSendOtp(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(OtpLoading());

    try {
      if (event.phoneNumber.isEmpty) {
        emit(const OtpFailure("Enter mobile number"));
        return;
      }

      final data = await _authRepository.sendOtp(event.phoneNumber);

      emit(OtpSent(message: data['message'], expiresIn: data['expires_in']));
    } catch (e) {
      emit(OtpFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyLoading());

    try {
      if (event.phoneNumber.isEmpty) {
        emit(const OtpFailure("Enter mobile number"));
        return;
      }
      if (event.otp.isEmpty) {
        emit(const OtpFailure("Enter OTP"));
        return;
      }
      if (event.otp.length != 4) {
        emit(const OtpFailure("The OTP is not 4 digits"));
        return;
      }

      final data = await _authRepository.verifyOtp(
        event.phoneNumber,
        event.otp,
      );

      emit(
        VerifySent(
          message: data['message'],
          phoneNumber: data['phone_number'],
          resetToken: data['reset_token'],
        ),
      );
    } catch (e) {
      emit(OtpFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordLoading());

    try {
      if (event.resetToken.isEmpty) {
        emit(const OtpFailure("Retry again. Something went wrong"));
        return;
      }
      if (event.newPassword.isEmpty) {
        emit(const OtpFailure("Enter new password"));
        return;
      }
      if (event.confirmPassword.isEmpty) {
        emit(const OtpFailure("Confirm new password"));
        return;
      }

      if (event.newPassword != event.confirmPassword) {
        emit(const OtpFailure("Passwords do not match"));
        return;
      }

      final data = await _authRepository.resetPassword(
        event.phoneNumber,
        event.newPassword,
        event.resetToken,
      );

      emit(
        ResetPasswordSent(
          message: data['message'],
          phoneNumber: data['phone_number'],
        ),
      );
    } catch (e) {
      emit(OtpFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(LogoutLoading());

    try {
      final token = await SecureStorageHelper.getToken();

      if (token != null) {
        await _authRepository.logout(token);
      }

      await SecureStorageHelper.deleteToken();

      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutFailure(e.toString()));
    }
  }
}
