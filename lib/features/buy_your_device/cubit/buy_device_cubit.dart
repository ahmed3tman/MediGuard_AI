import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// States
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

// Cubit
class BuyDeviceCubit extends Cubit<BuyDeviceState> {
  BuyDeviceCubit() : super(BuyDeviceInitial());

  void buyDevice() async {
    emit(BuyDeviceLoading());
    await Future.delayed(const Duration(seconds: 2));
    // Simulate success
    emit(BuyDeviceSuccess());
    // To simulate error, use:
    // emit(BuyDeviceError('حدث خطأ أثناء الشراء'));
  }
}
