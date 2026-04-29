import 'package:dtrs_survey/features/auth/data/models/auth_models.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class OtpLoading extends AuthState {}

class OtpSent extends AuthState {
  final String message;
  final int expiresIn;

  const OtpSent({required this.message, required this.expiresIn});

  @override
  List<Object> get props => [message, expiresIn];
}

class OtpFailure extends AuthState {
  final String error;

  const OtpFailure(this.error);

  @override
  List<Object> get props => [error];
}

class VerifyLoading extends AuthState {}

class VerifySent extends AuthState {
  final String message;
  final String phoneNumber;
  final String resetToken;

  const VerifySent({
    required this.message,
    required this.phoneNumber,
    required this.resetToken,
  });

  @override
  List<Object> get props => [message, phoneNumber, resetToken];
}

class ResetPasswordLoading extends AuthState {}

class ResetPasswordSent extends AuthState {
  final String message;
  final String phoneNumber;

  const ResetPasswordSent({required this.message, required this.phoneNumber});

  @override
  List<Object> get props => [message, phoneNumber];
}
class LogoutLoading extends AuthState {}

class LogoutSuccess extends AuthState {}

class LogoutFailure extends AuthState {
  final String error;
  const LogoutFailure(this.error);

  @override
  List<Object> get props => [error];
}

