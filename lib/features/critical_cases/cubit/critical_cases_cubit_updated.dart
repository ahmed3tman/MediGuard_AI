import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_doctor/features/auth/services/auth_service.dart';
import 'package:spider_doctor/features/critical_cases/model/critical_case_model.dart';
import 'package:spider_doctor/features/critical_cases/services/firebase_critical_cases_service.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'critical_cases_state.dart';

class CriticalCasesCubit extends Cubit<CriticalCasesState> {
  /// تحديث بيانات الحالات الحرجة من قائمة الأجهزة
  void updateCriticalCasesFromDevices(List<Device> devices) async {
    bool updated = false;
    for (final device in devices) {
      final idx = _criticalCases.indexWhere(
        (c) => c.deviceId == device.deviceId,
      );
      if (idx != -1) {
        final old = _criticalCases[idx];
        // إذا تغيرت البيانات فعلاً (بدون ecgData)
        if (old.temperature != device.temperature ||
            old.heartRate != device.heartRate ||
            old.spo2 != device.spo2 ||
            old.bloodPressure.toString() != device.bloodPressure.toString() ||
            old.lastUpdated != device.lastUpdated) {
          final updatedCase = old.copyWith(
            temperature: device.temperature,
            heartRate: device.heartRate,
            spo2: device.spo2,
            bloodPressure: device.bloodPressure,
            lastUpdated: device.lastUpdated ?? DateTime.now(),
          );
          _criticalCases[idx] = updatedCase;

          // حفظ في Firebase
          try {
            await FirebaseCriticalCasesService.updateCriticalCase(updatedCase);
          } catch (e) {
            print('Failed to update critical case in Firebase: $e');
          }

          updated = true;
        }
      }
    }
    if (updated) {
      await _saveToLocalStorage();
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    }
  }

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
        heartRate: device.heartRate,
        ecgData: const [], // تمرير قيمة افتراضية فارغة
        spo2: device.spo2,
        bloodPressure: device.bloodPressure,
        lastUpdated: device.lastUpdated ?? DateTime.now(),
      );
      if (!_criticalCases.any((c) => c.deviceId == device.deviceId)) {
        _criticalCases.add(criticalCase);

        // حفظ في Firebase أولاً
        try {
          await FirebaseCriticalCasesService.saveCriticalCase(criticalCase);
        } catch (e) {
          print('Failed to save critical case to Firebase: $e');
        }

        // حفظ محلياً كنسخة احتياطية
        await _saveToLocalStorage();
      }
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    } catch (e) {
      emit(CriticalCasesError('Failed to add critical case: ${e.toString()}'));
    }
  }

  Future<void> removeCriticalCase(String deviceId) async {
    emit(CriticalCasesLoading());
    try {
      _criticalCases.removeWhere((c) => c.deviceId == deviceId);

      // حذف من Firebase
      try {
        await FirebaseCriticalCasesService.deleteCriticalCase(deviceId);
      } catch (e) {
        print('Failed to delete critical case from Firebase: $e');
      }

      // حذف محلياً
      await _saveToLocalStorage();
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    } catch (e) {
      emit(
        CriticalCasesError('Failed to remove critical case: ${e.toString()}'),
      );
    }
  }

  Future<void> loadCriticalCases() async {
    try {
      // تحميل من Firebase أولاً
      final firebaseCases =
          await FirebaseCriticalCasesService.getAllCriticalCases();
      if (firebaseCases.isNotEmpty) {
        _criticalCases.clear();
        _criticalCases.addAll(firebaseCases);

        // تحديث التخزين المحلي
        await _saveToLocalStorage();
        emit(CriticalCasesLoaded(List.from(_criticalCases)));
        return;
      }
    } catch (e) {
      print('Failed to load critical cases from Firebase: $e');
    }

    // في حالة فشل Firebase، تحميل من التخزين المحلي
    await _loadFromLocalStorage();
  }

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    _criticalCases.clear();
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _criticalCases.addAll(jsonList.map((e) => CriticalCase.fromJson(e)));
    }
    emit(CriticalCasesLoaded(List.from(_criticalCases)));
  }

  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _criticalCases.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  bool isDeviceCritical(String deviceId) {
    return _criticalCases.any((c) => c.deviceId == deviceId);
  }

  /// مزامنة البيانات المحلية مع Firebase
  Future<void> syncToFirebase() async {
    try {
      for (final criticalCase in _criticalCases) {
        await FirebaseCriticalCasesService.saveCriticalCase(criticalCase);
      }
    } catch (e) {
      print('Failed to sync critical cases to Firebase: $e');
    }
  }
}
