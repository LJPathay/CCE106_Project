import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthState.unknown()) {
    // Check auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        add(AuthStatusChanged(true));
      } else {
        add(AuthStatusChanged(false));
      }
    });

    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(event.email));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthState.error('An unexpected error occurred'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.isAuthenticated) {
      emit(AuthState.authenticated(_auth.currentUser?.email ?? ''));
    } else {
      emit(AuthState.unauthenticated());
    }
  }
}
