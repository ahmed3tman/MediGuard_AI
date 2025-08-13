import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../auth/services/auth_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  StreamSubscription? _devicesSubscription;
  Map<String, dynamic> _userProfile = {};
  int _devicesCount = 0;

  ProfileCubit() : super(ProfileInitial());

  // Load user profile and devices count
  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        // Load user profile
        _userProfile = await AuthService.getUserProfile(user.uid) ?? {};

        // Load devices count
        _devicesCount = await AuthService.getUserDevicesCount(user.uid);

        // Setup devices listener for real-time count updates
        _setupDevicesListener();

        emit(
          ProfileLoaded(userProfile: _userProfile, devicesCount: _devicesCount),
        );
      } else {
        emit(const ProfileError('User not authenticated'));
      }
    } catch (e) {
      emit(ProfileError('Error loading profile: ${e.toString()}'));
    }
  }

  // Setup devices listener for real-time count updates
  void _setupDevicesListener() {
    final user = AuthService.currentUser;
    if (user != null) {
      final devicesRef = FirebaseDatabase.instance.ref(
        'users/${user.uid}/patients', // updated structure
      );

      _devicesSubscription = devicesRef.onValue.listen((event) {
        final data = event.snapshot.value;
        final count = data != null ? (data as Map).length : 0;
        _devicesCount = count;

        emit(
          ProfileLoaded(userProfile: _userProfile, devicesCount: _devicesCount),
        );
      });
    }
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    emit(ProfileUpdating());
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        // Update profile in Firebase
        await AuthService.updateUserProfile(user.uid, updates);

        // Update local profile
        _userProfile = {..._userProfile, ...updates};

        emit(ProfileUpdated());
        emit(
          ProfileLoaded(userProfile: _userProfile, devicesCount: _devicesCount),
        );
      } else {
        emit(const ProfileError('User not authenticated'));
      }
    } catch (e) {
      emit(ProfileError('Error updating profile: ${e.toString()}'));
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  // Ensure user profile exists
  Future<void> ensureUserProfile() async {
    try {
      await AuthService.ensureUserProfile();
    } catch (e) {
      emit(ProfileError('Error ensuring user profile: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    return super.close();
  }
}
