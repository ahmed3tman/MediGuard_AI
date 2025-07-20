import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/patient_detail_service.dart';
import '../model/patient_vital_signs.dart';
import 'patient_detail_state.dart';

/// Cubit for managing patient detail screen state and real-time data
class PatientDetailCubit extends Cubit<PatientDetailState> {
  final String deviceId;
  final String patientName;

  StreamSubscription? _vitalSignsSubscription;
  StreamSubscription? _ecgSubscription;

  PatientVitalSigns? _currentVitalSigns;
  List<EcgReading> _currentEcgReadings = [];

  PatientDetailCubit({required this.deviceId, required this.patientName})
    : super(PatientDetailInitial());

  /// Initialize real-time data streaming
  Future<void> initialize() async {
    emit(PatientDetailLoading());

    try {
      // Start listening to vital signs updates - real data only
      _vitalSignsSubscription =
          PatientDetailService.getPatientVitalSignsStream(deviceId).listen(
            (vitalSigns) {
              print('Vital signs received: $vitalSigns');
              if (vitalSigns != null) {
                print('Heart rate from vital signs: ${vitalSigns.heartRate}');
                print('Device connected: ${vitalSigns.isDeviceConnected}');
                print('Connection status: ${vitalSigns.connectionStatus}');
                _currentVitalSigns = vitalSigns;
                _updateState();
              }
            },
            onError: (error) {
              print('Error loading vital signs: $error');
              emit(PatientDetailError('Error loading vital signs: $error'));
            },
          );

      // Start listening to ECG data updates - real data only
      _ecgSubscription = PatientDetailService.getEcgReadingsStream(deviceId)
          .listen(
            (ecgReadings) {
              print(
                'ECG data received in cubit: ${ecgReadings.length} readings',
              );
              _currentEcgReadings = ecgReadings;
              _updateState();
            },
            onError: (error) {
              print('Error loading ECG data: $error');
              // Don't emit error for ECG, just use empty list
              _currentEcgReadings = [];
              _updateState();
            },
          );
    } catch (e) {
      emit(PatientDetailError('Failed to initialize patient monitoring: $e'));
    }
  }

  /// Update the state when new data arrives
  void _updateState() {
    if (_currentVitalSigns != null) {
      print('Updating state - ECG readings: ${_currentEcgReadings.length}');
      print(
        'Device connection status: ${_currentVitalSigns!.connectionStatus}',
      );
      emit(
        PatientDetailLoaded(
          vitalSigns: _currentVitalSigns!,
          ecgReadings: _currentEcgReadings,
        ),
      );
    }
  }

  /// Manually refresh data (trigger new Firebase reads)
  Future<void> refreshData() async {
    // Just trigger a re-read from Firebase by reinitializing
    await initialize();
  }

  /// Clean up old data to prevent database bloat
  Future<void> cleanupOldData() async {
    try {
      await PatientDetailService.cleanupOldEcgData(deviceId);
    } catch (e) {
      print('Error cleaning up old data: $e');
    }
  }

  /// Get current vital signs
  PatientVitalSigns? get currentVitalSigns => _currentVitalSigns;

  /// Get current ECG readings
  List<EcgReading> get currentEcgReadings => _currentEcgReadings;

  @override
  Future<void> close() {
    _vitalSignsSubscription?.cancel();
    _ecgSubscription?.cancel();
    return super.close();
  }
}
