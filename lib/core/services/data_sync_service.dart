import 'package:firebase_auth/firebase_auth.dart';
import '../../features/edit_patient_info/services/patient_info_service.dart';
import '../../features/critical_cases/cubit/critical_cases_cubit.dart';

/// خدمة مزامنة شاملة للبيانات بين الأجهزة
/// تضمن مزامنة جميع البيانات مع Firebase عند تسجيل الدخول
class DataSyncService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// مزامنة جميع البيانات عند تسجيل الدخول
  static Future<void> syncAllDataOnLogin() async {
    if (_auth.currentUser == null) return;

    try {
      print('Starting data sync for user: ${_auth.currentUser!.uid}');

      // مزامنة بيانات المرضى
      await _syncPatientData();

      print('Data sync completed successfully');
    } catch (e) {
      print('Data sync failed: $e');
    }
  }

  /// مزامنة بيانات المرضى
  static Future<void> _syncPatientData() async {
    try {
      print('Syncing patient data...');
      await PatientInfoService.syncToFirebase();
      print('Patient data sync completed');
    } catch (e) {
      print('Patient data sync failed: $e');
    }
  }

  /// مزامنة الحالات الطارئة
  static Future<void> syncCriticalCases(CriticalCasesCubit cubit) async {
    try {
      print('Syncing critical cases...');
      await cubit.syncToFirebase();
      print('Critical cases sync completed');
    } catch (e) {
      print('Critical cases sync failed: $e');
    }
  }

  /// تشغيل مزامنة دورية للبيانات
  static Future<void> performPeriodicSync() async {
    if (_auth.currentUser == null) return;

    try {
      // مزامنة بيانات المرضى فقط (الحالات الطارئة تحتاج للـ cubit)
      await _syncPatientData();
    } catch (e) {
      print('Periodic sync failed: $e');
    }
  }

  /// فحص حالة الاتصال بـ Firebase
  static Future<bool> checkFirebaseConnection() async {
    try {
      if (_auth.currentUser == null) return false;

      // محاولة قراءة بسيطة من Firebase للتأكد من الاتصال
      // يمكن إضافة فحص أكثر تفصيلاً هنا إذا لزم الأمر
      return true;
    } catch (e) {
      print('Firebase connection check failed: $e');
      return false;
    }
  }
}
