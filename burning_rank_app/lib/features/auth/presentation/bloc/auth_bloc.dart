import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:burning_rank_app/features/auth/domain/entities/user_model.dart';
import 'package:burning_rank_app/features/auth/domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthAppStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {}

class AuthGuestLoginRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthGuest extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthGuestLoginRequested>(_onGuestLoginRequested);
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.checkAuthStatus();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithApple();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailure("Sign in cancelled or failed"));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGuestLoginRequested(
    AuthGuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGuest());
  }
}
