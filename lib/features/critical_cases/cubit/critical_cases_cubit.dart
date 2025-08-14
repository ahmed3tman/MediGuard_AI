import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_doctor/features/auth/services/auth_service.dart';
import 'package:spider_doctor/features/critical_cases/model/critical_case_model.dart';
import 'package:spider_doctor/features/critical_cases/services/firebase_critical_cases_service.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'package:spider_doctor/features/edit_patient_info/services/patient_info_service.dart';
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

        // الحصول على اسم المريض من معلومات المريض
        String patientName = device.name; // القيمة الافتراضية
        try {
          final patientInfo = await PatientInfoService.getPatientInfo(
            device.deviceId,
          );
          if (patientInfo?.patientName != null &&
              patientInfo!.patientName!.isNotEmpty) {
            patientName = patientInfo.patientName!;
          }
        } catch (e) {
          print('Failed to get patient name for device ${device.deviceId}: $e');
        }

        // إذا تغيرت البيانات فعلاً (بما في ذلك الاسم)
        if (old.temperature != device.temperature ||
            old.heartRate != device.heartRate ||
            old.spo2 != device.spo2 ||
            old.bloodPressure.toString() != device.bloodPressure.toString() ||
            old.lastUpdated != device.lastUpdated ||
            old.name != patientName) {
          final updatedCase = old.copyWith(
            name: patientName,
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
      // الحصول على اسم المريض من معلومات المريض
      String patientName = device.name; // القيمة الافتراضية
      try {
        final patientInfo = await PatientInfoService.getPatientInfo(
          device.deviceId,
        );
        if (patientInfo?.patientName != null &&
            patientInfo!.patientName!.isNotEmpty) {
          patientName = patientInfo.patientName!;
        }
      } catch (e) {
        print('Failed to get patient name for device ${device.deviceId}: $e');
      }

      final criticalCase = CriticalCase(
        deviceId: device.deviceId,
        name: patientName,
        temperature: device.temperature,
        heartRate: device.heartRate,
        respiratoryRate: device.respiratoryRate,
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
    // إصدار state للحذف مع عرض loading في مكان الأيقونة
    emit(CriticalCaseDeleting(List.from(_criticalCases), deviceId));
    try {
      // حفظ الحالة المحذوفة للتراجع في حالة فشل Firebase
      final removedCase = _criticalCases.firstWhere(
        (c) => c.deviceId == deviceId,
        orElse: () => throw Exception('Critical case not found'),
      );

      _criticalCases.removeWhere((c) => c.deviceId == deviceId);

      // حذف من Firebase أولاً
      bool firebaseDeleteSuccess = false;
      try {
        await FirebaseCriticalCasesService.deleteCriticalCase(deviceId);
        firebaseDeleteSuccess = true;
        print('Successfully deleted from Firebase: $deviceId');
      } catch (e) {
        print('Failed to delete critical case from Firebase: $e');

        // في حالة فشل Firebase، أعد الحالة إلى القائمة
        if (e.toString().contains('User not authenticated')) {
          _criticalCases.add(removedCase);
          emit(CriticalCasesError('يرجى تسجيل الدخول أولاً'));
          return;
        }

        // إذا كان الخطأ مرتبط بالشبكة، احذف محلياً وأخبر المستخدم
        print('Network error - deleting locally, will sync later');
      }

      // حذف محلياً
      await _saveToLocalStorage();
      emit(CriticalCasesLoaded(List.from(_criticalCases)));

      // إظهار رسالة للمستخدم حول حالة الحذف
      if (!firebaseDeleteSuccess) {
        print('تم الحذف محلياً، سيتم المزامنة عند توفر الاتصال');
      }
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

  /// مزامنة أسماء جميع الحالات الحرجة مع أسماء المرضى
  Future<void> syncAllNamesWithPatientInfo() async {
    bool updated = false;

    for (int idx = 0; idx < _criticalCases.length; idx++) {
      final criticalCase = _criticalCases[idx];
      try {
        final patientInfo = await PatientInfoService.getPatientInfo(
          criticalCase.deviceId,
        );
        if (patientInfo?.patientName != null &&
            patientInfo!.patientName!.isNotEmpty &&
            criticalCase.name != patientInfo.patientName) {
          final updatedCase = criticalCase.copyWith(
            name: patientInfo.patientName!,
          );
          _criticalCases[idx] = updatedCase;

          // محاولة تحديث في Firebase
          try {
            await FirebaseCriticalCasesService.updateCriticalCase(updatedCase);
          } catch (e) {
            print('Failed to update critical case name in Firebase: $e');
          }

          updated = true;
        }
      } catch (e) {
        print(
          'Failed to get patient info for critical case ${criticalCase.deviceId}: $e',
        );
      }
    }

    if (updated) {
      await _saveToLocalStorage();
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    }
  }

  /// مزامنة البيانات المحلية مع Firebase
  Future<void> syncToFirebase() async {
    try {
      for (final criticalCase in _criticalCases) {
        await FirebaseCriticalCasesService.saveCriticalCase(criticalCase);
      }
      print(
        'Successfully synced ${_criticalCases.length} critical cases to Firebase',
      );
    } catch (e) {
      print('Failed to sync critical cases to Firebase: $e');
      throw Exception('فشل في مزامنة البيانات مع الخادم: $e');
    }
  }

  /// التحقق من تطابق البيانات المحلية مع Firebase
  Future<bool> verifyDataConsistency() async {
    try {
      final firebaseCases =
          await FirebaseCriticalCasesService.getAllCriticalCases();

      // مقارنة عدد الحالات
      if (firebaseCases.length != _criticalCases.length) {
        print(
          'Data inconsistency: Firebase has ${firebaseCases.length} cases, local has ${_criticalCases.length}',
        );
        return false;
      }

      // مقارنة كل حالة
      for (final localCase in _criticalCases) {
        final firebaseCase = firebaseCases.firstWhere(
          (c) => c.deviceId == localCase.deviceId,
          orElse: () => throw Exception(
            'Case ${localCase.deviceId} not found in Firebase',
          ),
        );

        if (localCase.name != firebaseCase.name) {
          print('Data inconsistency found for device: ${localCase.deviceId}');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error verifying data consistency: $e');
      return false;
    }
  }

  /// إجبار إعادة المزامنة من Firebase
  Future<void> forceResyncFromFirebase() async {
    try {
      emit(CriticalCasesLoading());

      // تحميل البيانات من Firebase
      final firebaseCases =
          await FirebaseCriticalCasesService.getAllCriticalCases();

      // استبدال البيانات المحلية
      _criticalCases.clear();
      _criticalCases.addAll(firebaseCases);

      // حفظ البيانات الجديدة محلياً
      await _saveToLocalStorage();

      emit(CriticalCasesLoaded(List.from(_criticalCases)));
      print(
        'Successfully resynced ${_criticalCases.length} critical cases from Firebase',
      );
    } catch (e) {
      print('Failed to resync from Firebase: $e');
      // في حالة الفشل، احتفظ بالبيانات المحلية
      emit(CriticalCasesLoaded(List.from(_criticalCases)));
      throw Exception('فشل في إعادة المزامنة من الخادم: $e');
    }
  }

  /// الحصول على إحصائيات حول حالة البيانات
  Map<String, dynamic> getDataStatus() {
    return {
      'localCasesCount': _criticalCases.length,
      'lastLocalUpdate': _criticalCases.isNotEmpty
          ? _criticalCases
                .map((c) => c.lastUpdated)
                .reduce((a, b) => a.isAfter(b) ? a : b)
                .toIso8601String()
          : null,
      'devices': _criticalCases
          .map(
            (c) => {
              'deviceId': c.deviceId,
              'name': c.name,
              'lastUpdated': c.lastUpdated.toIso8601String(),
            },
          )
          .toList(),
    };
  }
}
