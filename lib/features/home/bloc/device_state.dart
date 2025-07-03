import 'package:equatable/equatable.dart';
import '../model/data_model.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<Device> devices;

  const DeviceLoaded(this.devices);

  @override
  List<Object> get props => [devices];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object> get props => [message];
}

class DeviceAdding extends DeviceState {}

class DeviceAdded extends DeviceState {}

class DeviceDeleting extends DeviceState {}

class DeviceDeleted extends DeviceState {}
