import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/critical_case_model.dart';

/// Firebase service for critical cases
/// Stores critical cases in Firebase Realtime Database for cross-device sync
class FirebaseCriticalCasesService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Save critical case to Firebase
  static Future<void> saveCriticalCase(CriticalCase criticalCase) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final criticalCaseRef = _database.ref(
        'users/$currentUserId/criticalCases/${criticalCase.deviceId}',
      );
      await criticalCaseRef.set(criticalCase.toJson());
      print('Critical case saved to Firebase: ${criticalCase.deviceId}');
    } catch (e) {
      throw Exception('Failed to save critical case to Firebase: $e');
    }
  }

  /// Get all critical cases from Firebase
  static Future<List<CriticalCase>> getAllCriticalCases() async {
    if (currentUserId == null) return [];

    try {
      final criticalCasesRef = _database.ref(
        'users/$currentUserId/criticalCases',
      );
      final snapshot = await criticalCasesRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        return data.values
            .map(
              (caseData) => CriticalCase.fromJson(
                Map<String, dynamic>.from(caseData as Map),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting critical cases from Firebase: $e');
      return [];
    }
  }

  /// Update critical case in Firebase
  static Future<void> updateCriticalCase(CriticalCase criticalCase) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final criticalCaseRef = _database.ref(
        'users/$currentUserId/criticalCases/${criticalCase.deviceId}',
      );

      // التحقق من وجود البيانات قبل التحديث
      final existingSnapshot = await criticalCaseRef.get();
      if (!existingSnapshot.exists) {
        // إذا لم تكن البيانات موجودة، احفظها بدلاً من التحديث
        await saveCriticalCase(criticalCase);
        return;
      }

      // استخدام update بدلاً من set للحفاظ على البيانات الأخرى
      await criticalCaseRef.update(criticalCase.toJson());

      // التحقق من نجاح التحديث
      final verifySnapshot = await criticalCaseRef.get();
      if (verifySnapshot.exists) {
        print(
          'Critical case successfully updated in Firebase: ${criticalCase.deviceId}',
        );
      } else {
        throw Exception(
          'Update operation failed - data not found after update',
        );
      }
    } catch (e) {
      throw Exception('Failed to update critical case in Firebase: $e');
    }
  }

  /// Delete critical case from Firebase
  static Future<void> deleteCriticalCase(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final criticalCaseRef = _database.ref(
        'users/$currentUserId/criticalCases/$deviceId',
      );

      // التحقق من وجود البيانات قبل الحذف
      final snapshot = await criticalCaseRef.get();
      if (!snapshot.exists) {
        print('Critical case already deleted or does not exist: $deviceId');
        return;
      }

      await criticalCaseRef.remove();

      // التحقق من نجاح الحذف
      final verifySnapshot = await criticalCaseRef.get();
      if (!verifySnapshot.exists) {
        print('Critical case successfully deleted from Firebase: $deviceId');
      } else {
        throw Exception('Delete operation failed - data still exists');
      }
    } catch (e) {
      throw Exception('Failed to delete critical case from Firebase: $e');
    }
  }

  /// Check if device is in critical cases
  static Future<bool> isDeviceCritical(String deviceId) async {
    try {
      final criticalCasesRef = _database.ref(
        'users/$currentUserId/criticalCases/$deviceId',
      );
      final snapshot = await criticalCasesRef.get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Listen to real-time critical cases changes
  static Stream<List<CriticalCase>> getCriticalCasesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _database.ref('users/$currentUserId/criticalCases').onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      if (data == null) return <CriticalCase>[];

      try {
        final casesMap = Map<dynamic, dynamic>.from(data as Map);
        return casesMap.values
            .map(
              (caseData) => CriticalCase.fromJson(
                Map<String, dynamic>.from(caseData as Map),
              ),
            )
            .toList();
      } catch (e) {
        print('Error parsing critical cases from stream: $e');
        return <CriticalCase>[];
      }
    });
  }

  /// Listen to specific critical case changes
  static Stream<CriticalCase?> getCriticalCaseStream(String deviceId) {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _database
        .ref('users/$currentUserId/criticalCases/$deviceId')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return null;

          try {
            return CriticalCase.fromJson(
              Map<String, dynamic>.from(data as Map),
            );
          } catch (e) {
            print('Error parsing critical case from stream: $e');
            return null;
          }
        });
  }

  /// Batch update multiple critical cases
  static Future<void> batchUpdateCriticalCases(
    List<CriticalCase> criticalCases,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{};
      for (final criticalCase in criticalCases) {
        updates['users/$currentUserId/criticalCases/${criticalCase.deviceId}'] =
            criticalCase.toJson();
      }

      await _database.ref().update(updates);
      print('Batch updated ${criticalCases.length} critical cases');
    } catch (e) {
      throw Exception('Failed to batch update critical cases: $e');
    }
  }
}
