import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  StreamSubscription<User?>? _authSubscription;

  AuthCubit() : super(AuthInitial()) {
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() {
    _authSubscription?.cancel();
    _authSubscription = AuthService.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    }, onError: (error) => emit(AuthError(error.toString())));
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(AuthSigningIn());
    try {
      await AuthService.signInWithEmailAndPassword(email, password);
      // State will be updated through the stream listener
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Create user with email and password
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    emit(AuthSigningUp());
    try {
      await AuthService.createUserWithEmailAndPassword(email, password, name);
      // State will be updated through the stream listener
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Sign in anonymously
  Future<void> signInAnonymously() async {
    emit(AuthSigningIn());
    try {
      await AuthService.signInAnonymously();
      // State will be updated through the stream listener
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Sign out
  Future<void> signOut() async {
    emit(AuthSigningOut());
    try {
      await AuthService.signOut();
      // State will be updated through the stream listener
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Check if user is signed in
  bool get isSignedIn => AuthService.isSignedIn;

  // Get current user
  User? get currentUser => AuthService.currentUser;

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      return await AuthService.getUserProfile(uid);
    } catch (e) {
      emit(AuthError(e.toString()));
      return null;
    }
  }

  // Ensure user profile exists
  Future<void> ensureUserProfile() async {
    try {
      await AuthService.ensureUserProfile();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
