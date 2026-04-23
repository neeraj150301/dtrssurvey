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
}
