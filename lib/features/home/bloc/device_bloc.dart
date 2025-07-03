import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/device_service.dart';
import '../model/data_model.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  StreamSubscription? _devicesSubscription;
  final Map<String, StreamSubscription> _externalReadingsSubscriptions = {};

  DeviceBloc() : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<AddDevice>(_onAddDevice);
    on<DeleteDevice>(_onDeleteDevice);
    on<SimulateDeviceData>(_onSimulateDeviceData);
    on<DevicesUpdated>(_onDevicesUpdated);
    on<ListenToExternalReadings>(_onListenToExternalReadings);
    on<ExternalReadingsReceived>(_onExternalReadingsReceived);
  }

  void _onLoadDevices(LoadDevices event, Emitter<DeviceState> emit) {
    emit(DeviceLoading());

    _devicesSubscription?.cancel();
    _devicesSubscription = DeviceService.getDevicesStream().listen(
      (devices) => add(DevicesUpdated(devices)),
      onError: (error) => emit(DeviceError(error.toString())),
    );
  }

  Future<void> _onAddDevice(AddDevice event, Emitter<DeviceState> emit) async {
    emit(DeviceAdding());
    try {
      await DeviceService.addDevice(event.deviceId, event.deviceName);
      emit(DeviceAdded());
      add(LoadDevices()); // Reload devices after adding
    } catch (e) {
      emit(DeviceError('Failed to add device: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteDevice(
    DeleteDevice event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceDeleting());
    try {
      await DeviceService.deleteDevice(event.deviceId);

      // Cancel the external readings subscription for deleted device
      _externalReadingsSubscriptions[event.deviceId]?.cancel();
      _externalReadingsSubscriptions.remove(event.deviceId);

      emit(DeviceDeleted());
      add(LoadDevices()); // Reload devices after deleting
    } catch (e) {
      emit(DeviceError('Failed to delete device: ${e.toString()}'));
    }
  }

  Future<void> _onSimulateDeviceData(
    SimulateDeviceData event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      await DeviceService.simulateDeviceData(event.deviceId);
    } catch (e) {
      emit(DeviceError('Failed to simulate device data: ${e.toString()}'));
    }
  }

  void _onDevicesUpdated(DevicesUpdated event, Emitter<DeviceState> emit) {
    final devices = List<Device>.from(event.devices);

    // Start listening to external readings for each device
    for (final device in devices) {
      add(ListenToExternalReadings(device.deviceId));
    }

    emit(DeviceLoaded(devices));
  }

  void _onListenToExternalReadings(
    ListenToExternalReadings event,
    Emitter<DeviceState> emit,
  ) {
    final deviceId = event.deviceId;

    // Cancel existing subscription if any
    _externalReadingsSubscriptions[deviceId]?.cancel();

    // Listen to external readings for this device
    _externalReadingsSubscriptions[deviceId] =
        DeviceService.getExternalDeviceReadings(deviceId).listen(
          (readings) {
            if (readings != null) {
              add(ExternalReadingsReceived(deviceId, readings));
            }
          },
          onError: (error) {
            // Handle error silently - device might not be sending data
          },
        );
  }

  Future<void> _onExternalReadingsReceived(
    ExternalReadingsReceived event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      await DeviceService.updateDeviceWithExternalReadings(
        event.deviceId,
        event.readings,
      );
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
