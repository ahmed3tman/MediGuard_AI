import 'package:equatable/equatable.dart';

abstract class BuyDeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BuyDeviceInitial extends BuyDeviceState {}

class BuyDeviceLoading extends BuyDeviceState {}

class BuyDeviceSuccess extends BuyDeviceState {}

class BuyDeviceError extends BuyDeviceState {
  final String message;
  BuyDeviceError(this.message);
  @override
  List<Object?> get props => [message];
}
