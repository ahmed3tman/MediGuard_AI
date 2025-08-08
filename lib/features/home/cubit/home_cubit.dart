import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/home_data_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  // Load home data
  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      // Simulate loading time
      await Future.delayed(const Duration(milliseconds: 500));

      final devicePromotions = HomeDataRepository.getDevicePromotions();
      final healthTips = HomeDataRepository.getHealthTips();

      emit(
        HomeLoaded(
          devicePromotion: devicePromotions.first,
          healthTips: healthTips,
        ),
      );
    } catch (e) {
      emit(HomeError(message: 'Failed to load home data: ${e.toString()}'));
    }
  }

  // Refresh home data
  Future<void> refreshHomeData() async {
    await loadHomeData();
  }
}
