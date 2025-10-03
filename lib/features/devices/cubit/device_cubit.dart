import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/device_service.dart';
import '../model/data_model.dart';
import 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  StreamSubscription? _devicesSubscription;
  final Map<String, StreamSubscription> _externalReadingsSubscriptions = {};

  DeviceCubit() : super(DeviceInitial());

  // Load devices from the service (now collected from patients subtree)
  void loadDevices() {
    emit(DeviceLoading());

    _devicesSubscription?.cancel();
    _devicesSubscription = DeviceService.getDevicesStream().listen(
      (devices) => _onDevicesUpdated(devices),
      onError: (error) => emit(DeviceError(error.toString())),
    );
  }

  // Add a new device
  Future<void> addDevice(
    String deviceId,
    String deviceName, {
    bool allowCreatePlaceholder = false,
  }) async {
    emit(DeviceAdding());
    try {
      await DeviceService.addDevice(
        deviceId,
        deviceName,
        createPlaceholderIfMissing: allowCreatePlaceholder,
      );

      if (allowCreatePlaceholder) {
        await DeviceService.simulateDeviceData(deviceId);
      }
      emit(DeviceAdded());
      loadDevices(); // Reload devices after adding
    } catch (e) {
      emit(DeviceError('Failed to add device: ${e.toString()}'));
    }
  }

  // Delete a device
  Future<void> deleteDevice(String deviceId) async {
    emit(DeviceDeleting());
    try {
      await DeviceService.deleteDevice(deviceId);

      // Cancel the external readings subscription for deleted device
      _externalReadingsSubscriptions[deviceId]?.cancel();
      _externalReadingsSubscriptions.remove(deviceId);

      emit(DeviceDeleted());
      loadDevices(); // Reload devices after deleting
    } catch (e) {
      emit(DeviceError('Failed to delete device: ${e.toString()}'));
    }
  }

  // Update device name
  Future<void> updateDeviceName(String deviceId, String newName) async {
    try {
      await DeviceService.updateDeviceName(deviceId, newName);
      // No need to emit states as the stream will automatically update
    } catch (e) {
      emit(DeviceError('Failed to update device name: ${e.toString()}'));
    }
  }

  // Simulate device data
  Future<void> simulateDeviceData(String deviceId) async {
    try {
      await DeviceService.simulateDeviceData(deviceId);
    } catch (e) {
      emit(DeviceError('Failed to simulate device data: ${e.toString()}'));
    }
  }

  // Handle devices updated from stream
  void _onDevicesUpdated(List devices) {
    final deviceList = List<Device>.from(devices);

    // Start listening to external readings for each device
    for (final device in deviceList) {
      _listenToExternalReadings(device.deviceId);
    }

    emit(DeviceLoaded(deviceList));
  }

  // Listen to external readings for a device
  void _listenToExternalReadings(String deviceId) {
    // Cancel existing subscription if any
    _externalReadingsSubscriptions[deviceId]?.cancel();

    // Listen to external readings for this device
    _externalReadingsSubscriptions[deviceId] =
        DeviceService.getExternalDeviceReadings(deviceId).listen(
          (readings) {
            if (readings != null) {
              _onExternalReadingsReceived(deviceId, readings);
            }
          },
          onError: (error) {
            // Handle error silently - device might not be sending data
          },
        );
  }

  // Handle external readings received
  Future<void> _onExternalReadingsReceived(
    String deviceId,
    Map<String, dynamic> readings,
  ) async {
    try {
      await DeviceService.updateDeviceWithExternalReadings(deviceId, readings);
    } catch (e) {
      // Handle error silently - don't interrupt the flow
    }
  }

  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    // Cancel all external readings subscriptions
    for (final subscription in _externalReadingsSubscriptions.values) {
      subscription.cancel();
    }
    _externalReadingsSubscriptions.clear();
    return super.close();
  }
}
