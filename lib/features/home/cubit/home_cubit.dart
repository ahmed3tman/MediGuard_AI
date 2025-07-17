import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  // Load dashboard data
  Future<void> loadDashboard() async {
    emit(HomeLoading());
    try {
      // Simulate loading dashboard data
      await Future.delayed(const Duration(seconds: 1));

      final dashboardData = {
        'totalDevices': 0,
        'activeDevices': 0,
        'criticalAlerts': 0,
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      emit(HomeLoaded(dashboardData));
    } catch (e) {
      emit(HomeError('Failed to load dashboard: ${e.toString()}'));
    }
  }

  // Refresh dashboard
  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}
