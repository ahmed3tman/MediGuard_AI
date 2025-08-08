import 'package:equatable/equatable.dart';
import '../models/health_models.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DevicePromotion devicePromotion;
  final List<HealthTip> healthTips;

  const HomeLoaded({required this.devicePromotion, required this.healthTips});

  @override
  List<Object?> get props => [devicePromotion, healthTips];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
