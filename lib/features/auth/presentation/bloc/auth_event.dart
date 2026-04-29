import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  const LoginRequested({required this.identifier, required this.password});

  @override
  List<Object> get props => [identifier, password];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOtpRequested({required this.phoneNumber, required this.otp});

  @override
  List<Object> get props => [phoneNumber, otp];
}

class ResetPasswordRequested extends AuthEvent {
  final String phoneNumber;
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequested({
    required this.phoneNumber,
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [
    phoneNumber,
    resetToken,
    newPassword,
    confirmPassword,
  ];
}

class LogoutRequested extends AuthEvent {}
