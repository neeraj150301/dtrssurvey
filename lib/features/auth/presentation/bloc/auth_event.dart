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
