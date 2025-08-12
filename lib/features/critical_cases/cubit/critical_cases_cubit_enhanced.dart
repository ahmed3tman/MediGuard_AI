import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_doctor/features/critical_cases/model/critical_case_model.dart';
import 'package:spider_doctor/features/critical_cases/services/firebase_critical_cases_service_enhanced.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_state.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'package:spider_doctor/features/auth/services/auth_service.dart';
import 'package:spider_doctor/features/patient_info/services/patient_info_service.dart';

part 'critical_cases_cubit_enhanced_state.dart';

class CriticalCasesCubitEnhanced extends Cubit<CriticalCasesState> {
  CriticalCasesCubitEnhanced() : super(const CriticalCasesLoaded([])) {
    loadCriticalCases();
  }

  final List<CriticalCase> _criticalCases = [];
  bool _hasInternetConnection = true;

  /// تحديث حالة الاتصال بالإنترنت
  void updateConnectionStatus(bool hasConnection) {
    final wasOffline = !_hasInternetConnection;
    _hasInternetConnection = hasConnection;

    // إذا عاد الاتصال بعد انقطاع، قم بمزامنة البيانات
    if (wasOffline && _hasInternetConnection) {
      _syncAfterReconnection();
    }
  }

  /// مزامنة البيانات بعد عودة الاتصال
  Future<void> _syncAfterReconnection() async {
    try {
      print('Internet connection restored, syncing data...');

      // إجبار المزامنة للتأكد من تطابق البيانات
      await FirebaseCriticalCasesServiceEnhanced.forceSyncCriticalCases(
        _criticalCases,
      );

      // إعادة تحميل البيانات من Firebase
      await loadCriticalCases();

      print('Data sync completed after reconnection');
    } catch (e) {
      print('Failed to sync data after reconnection: $e');
    }
  }

  /// تحديث الحالات الحرجة مع التحقق من تطابق البيانات
  Future<void> updateCriticalCasesFromDevice(Device device) async {
    bool updated = false;
    for (int idx = 0; idx < _criticalCases.length; idx++) {
      final old = _criticalCases[idx];
      if (old.deviceId == device.deviceId) {
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

          // محاولة حفظ في Firebase مع معالجة أفضل للأخطاء
          if (_hasInternetConnection) {
            try {
              await FirebaseCriticalCasesServiceEnhanced.updateCriticalCase(
                updatedCase,
              );
            } catch (e) {
              print('Failed to update critical case in Firebase: $e');
              // لا نرمي خطأ هنا لأن البيانات محفوظة محلياً
            }
          } else {
            print('No internet connection, update will be synced later');
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

  /// إضافة حالة حرجة مع التحقق من الازدواجية
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

      // التحقق من عدم وجود الحالة مسبقاً
      if (!_criticalCases.any((c) => c.deviceId == device.deviceId)) {
        _criticalCases.add(criticalCase);

        // حفظ في Firebase مع معالجة الأخطاء
        if (_hasInternetConnection) {
          try {
            await FirebaseCriticalCasesServiceEnhanced.saveCriticalCase(
              criticalCase,
            );
          } catch (e) {
            print('Failed to save critical case to Firebase: $e');
            // البيانات محفوظة محلياً، سيتم مزامنتها لاحقاً
          }
        } else {
          print('No internet connection, critical case will be synced later');
        }

        // حفظ محلياً كنسخة احتياطية
        await _saveToLocalStorage();
      } else {
        print('Critical case already exists for device: ${device.deviceId}');
      }

      emit(CriticalCasesLoaded(List.from(_criticalCases)));
    } catch (e) {
      emit(CriticalCasesError('Failed to add critical case: ${e.toString()}'));
    }
  }

  /// حذف حالة حرجة مع التحقق من النجاح
  Future<void> removeCriticalCase(String deviceId) async {
    // إصدار state للحذف مع عرض loading في مكان الأيقونة
    emit(CriticalCaseDeleting(List.from(_criticalCases), deviceId));
    try {
      // حفظ الحالة قبل الحذف للتراجع إذا فشل
      final removedCase = _criticalCases.firstWhere(
        (c) => c.deviceId == deviceId,
        orElse: () => throw Exception('Critical case not found'),
      );

      _criticalCases.removeWhere((c) => c.deviceId == deviceId);

      // محاولة حذف من Firebase مع معالجة الأخطاء
      bool firebaseDeleteSuccess = false;
      if (_hasInternetConnection) {
        try {
          await FirebaseCriticalCasesServiceEnhanced.deleteCriticalCase(
            deviceId,
          );
          firebaseDeleteSuccess = true;
          print('Successfully deleted critical case from Firebase: $deviceId');
        } catch (e) {
          print('Failed to delete critical case from Firebase: $e');
          // في حالة فشل الحذف من Firebase، نضع علامة للمزامنة لاحقاً
          if (e.toString().contains('not authenticated')) {
            // مشكلة في التوثيق - أعد الحالة وأرسل خطأ
            _criticalCases.add(removedCase);
            emit(
              CriticalCasesError(
                'Authentication required for Firebase operations',
              ),
            );
            return;
          }
        }
      } else {
        print('No internet connection, deletion will be synced later');
      }

      // حذف محلياً
      await _saveToLocalStorage();
      emit(CriticalCasesLoaded(List.from(_criticalCases)));

      // إذا فشل الحذف من Firebase ولكن نجح محلياً، أشر إلى ذلك
      if (_hasInternetConnection && !firebaseDeleteSuccess) {
        print(
          'Warning: Critical case deleted locally but Firebase deletion failed',
        );
      }
    } catch (e) {
      emit(
        CriticalCasesError('Failed to remove critical case: ${e.toString()}'),
      );
    }
  }

  /// تحميل الحالات الحرجة مع أولوية Firebase
  Future<void> loadCriticalCases() async {
    try {
      if (_hasInternetConnection) {
        // تحميل من Firebase أولاً
        final firebaseCases =
            await FirebaseCriticalCasesServiceEnhanced.getAllCriticalCases();
        if (firebaseCases.isNotEmpty) {
          _criticalCases.clear();
          _criticalCases.addAll(firebaseCases);

          // تحديث التخزين المحلي
          await _saveToLocalStorage();
          emit(CriticalCasesLoaded(List.from(_criticalCases)));
          return;
        }
      }
    } catch (e) {
      print('Failed to load critical cases from Firebase: $e');
    }

    // في حالة فشل Firebase أو عدم وجود اتصال، تحميل من التخزين المحلي
    await _loadFromLocalStorage();
  }

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    _criticalCases.clear();
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _criticalCases.addAll(jsonList.map((e) => CriticalCase.fromJson(e)));
      } catch (e) {
        print('Error loading critical cases from local storage: $e');
      }
    }
    emit(CriticalCasesLoaded(List.from(_criticalCases)));
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _criticalCases.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving critical cases to local storage: $e');
    }
  }

  bool isDeviceCritical(String deviceId) {
    return _criticalCases.any((c) => c.deviceId == deviceId);
  }

  /// مزامنة البيانات المحلية مع Firebase يدوياً
  Future<void> syncToFirebase() async {
    if (!_hasInternetConnection) {
      throw Exception('No internet connection available');
    }

    try {
      emit(CriticalCasesLoading());

      // إجبار المزامنة الكاملة
      await FirebaseCriticalCasesServiceEnhanced.forceSyncCriticalCases(
        _criticalCases,
      );

      // إعادة تحميل البيانات للتأكد من التطابق
      await loadCriticalCases();

      print('Manual sync completed successfully');
    } catch (e) {
      print('Failed to sync critical cases to Firebase: $e');
      emit(CriticalCasesError('Failed to sync data: ${e.toString()}'));
    }
  }

  /// التحقق من تطابق البيانات المحلية مع Firebase
  Future<bool> verifyDataConsistency() async {
    if (!_hasInternetConnection) {
      return false;
    }

    try {
      final firebaseCases =
          await FirebaseCriticalCasesServiceEnhanced.getAllCriticalCases();

      // مقارنة عدد الحالات
      if (firebaseCases.length != _criticalCases.length) {
        return false;
      }

      // مقارنة كل حالة
      for (final localCase in _criticalCases) {
        final firebaseCase = firebaseCases.firstWhere(
          (c) => c.deviceId == localCase.deviceId,
          orElse: () => throw Exception('Case not found in Firebase'),
        );

        // مقارنة البيانات الأساسية (تجاهل التوقيت الدقيق)
        if (localCase.temperature != firebaseCase.temperature ||
            localCase.heartRate != firebaseCase.heartRate ||
            localCase.spo2 != firebaseCase.spo2) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error verifying data consistency: $e');
      return false;
    }
  }

  /// إحصائيات حول حالة المزامنة
  Map<String, dynamic> getSyncStatus() {
    return {
      'hasConnection': _hasInternetConnection,
      'localCasesCount': _criticalCases.length,
      'lastLocalUpdate': _criticalCases.isNotEmpty
          ? _criticalCases
                .map((c) => c.lastUpdated)
                .reduce((a, b) => a.isAfter(b) ? a : b)
                .toIso8601String()
          : null,
    };
  }
}
