part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? email;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.email,
    this.error,
  });

  factory AuthState.unknown() => const AuthState();

  factory AuthState.authenticated(String email) => AuthState(
        status: AuthStatus.authenticated,
        email: email,
      );

  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );

  factory AuthState.loading() => const AuthState(
        status: AuthStatus.loading,
      );

  factory AuthState.error(String error) => AuthState(
        status: AuthStatus.unauthenticated,
        error: error,
      );

  @override
  List<Object?> get props => [status, email, error];

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }
}
