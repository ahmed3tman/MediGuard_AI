import 'package:equatable/equatable.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object> get props => [];
}

class LoadDevices extends DeviceEvent {}

class AddDevice extends DeviceEvent {
  final String deviceId;
  final String deviceName;

  const AddDevice(this.deviceId, this.deviceName);

  @override
  List<Object> get props => [deviceId, deviceName];
}

class DeleteDevice extends DeviceEvent {
  final String deviceId;

  const DeleteDevice(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class SimulateDeviceData extends DeviceEvent {
  final String deviceId;

  const SimulateDeviceData(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class DevicesUpdated extends DeviceEvent {
  final List devices;

  const DevicesUpdated(this.devices);

  @override
  List<Object> get props => [devices];
}

class ListenToExternalReadings extends DeviceEvent {
  final String deviceId;

  const ListenToExternalReadings(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class ExternalReadingsReceived extends DeviceEvent {
  final String deviceId;
  final Map<String, dynamic> readings;

  const ExternalReadingsReceived(this.deviceId, this.readings);

  @override
  List<Object> get props => [deviceId, readings];
}
