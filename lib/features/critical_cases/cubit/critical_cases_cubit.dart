import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_doctor/features/auth/services/auth_service.dart';
import 'package:spider_doctor/features/critical_cases/model/critical_case_model.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'critical_cases_state.dart';

class CriticalCasesCubit extends Cubit<CriticalCasesState> {
  String get _storageKey {
    final userId = AuthService.currentUser?.uid;
    return 'critical_cases_list_${userId ?? "guest"}';
  }

  CriticalCasesCubit() : super(const CriticalCasesLoaded([])) {
    loadCriticalCases();
  }

  final List<CriticalCase> _criticalCases = [];

  Future<void> addCriticalCase(Device device) async {
    emit(CriticalCasesLoading());
    try {
      final criticalCase = CriticalCase(
        deviceId: device.deviceId,
        name: device.name,
        temperature: device.temperature,
        ecg: device.ecg,
        spo2: device.spo2,
        bloodPressure: device.bloodPressure,
        lastUpdated: device.lastUpdated ?? DateTime.now(),
      );
      if (!_criticalCases.any((c) => c.deviceId == device.deviceId)) {
        _criticalCases.add(criticalCase);
        await _saveToStorage();
      }
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    } catch (e) {
      emit(CriticalCasesError('Failed to add critical case: e.toString()}'));
    }
  }

  Future<void> removeCriticalCase(String deviceId) async {
    emit(CriticalCasesLoading());
    try {
      _criticalCases.removeWhere((c) => c.deviceId == deviceId);
      await _saveToStorage();
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    } catch (e) {
      emit(
        CriticalCasesError('Failed to remove critical case: e.toString()}'),
      );
    }
  }

  Future<void> loadCriticalCases() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    _criticalCases.clear();
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _criticalCases.addAll(jsonList.map((e) => CriticalCase.fromJson(e)));
    }
    emit(CriticalCasesLoaded(List.from(_criticalCases)));
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _criticalCases.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  bool isDeviceCritical(String deviceId) {
    return _criticalCases.any((c) => c.deviceId == deviceId);
  }
}
