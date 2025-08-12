import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/critical_case_model.dart';

/// Enhanced Firebase service for critical cases
/// Provides improved error handling and retry mechanisms for better reliability
class FirebaseCriticalCasesServiceEnhanced {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Save critical case to Firebase with retry mechanism
  static Future<void> saveCriticalCase(CriticalCase criticalCase) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final criticalCaseRef = _database.ref(
          'users/$currentUserId/criticalCases/${criticalCase.deviceId}',
        );

        final dataToSave = criticalCase.toJson();
        dataToSave['lastUpdated'] = ServerValue.timestamp;

        await criticalCaseRef.set(dataToSave);

        // التحقق من نجاح الحفظ
        final verifySnapshot = await criticalCaseRef.get();
        if (verifySnapshot.exists) {
          print(
            'Critical case successfully saved to Firebase: ${criticalCase.deviceId}',
          );
          return;
        } else {
          throw Exception('Save operation failed - data not found after save');
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to save critical case: $e');

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to save critical case to Firebase after $maxRetries attempts: $e',
          );
        }

        // انتظار قبل إعادة المحاولة
        await Future.delayed(Duration(seconds: retryCount));
      }
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

  /// Update critical case in Firebase with enhanced validation
  static Future<void> updateCriticalCase(CriticalCase criticalCase) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
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

        // إضافة timestamp للتحديث
        final dataToUpdate = criticalCase.toJson();
        dataToUpdate['lastUpdated'] = ServerValue.timestamp;

        await criticalCaseRef.update(dataToUpdate);

        // التحقق من نجاح التحديث
        final verifySnapshot = await criticalCaseRef.get();
        if (verifySnapshot.exists) {
          print(
            'Critical case successfully updated in Firebase: ${criticalCase.deviceId}',
          );
          return;
        } else {
          throw Exception(
            'Update operation failed - data not found after update',
          );
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to update critical case: $e');

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to update critical case in Firebase after $maxRetries attempts: $e',
          );
        }

        // انتظار قبل إعادة المحاولة
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  /// Delete critical case from Firebase with enhanced verification
  static Future<void> deleteCriticalCase(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
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

        // محاولة الحذف
        await criticalCaseRef.remove();

        // التحقق من نجاح الحذف
        final verifySnapshot = await criticalCaseRef.get();
        if (!verifySnapshot.exists) {
          print('Critical case successfully deleted from Firebase: $deviceId');
          return;
        } else {
          throw Exception('Delete operation did not complete');
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to delete critical case: $e');

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to delete critical case from Firebase after $maxRetries attempts: $e',
          );
        }

        // انتظار قبل إعادة المحاولة
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  /// Check if device is in critical cases with retry
  static Future<bool> isDeviceCritical(String deviceId) async {
    if (currentUserId == null) return false;

    try {
      final criticalCasesRef = _database.ref(
        'users/$currentUserId/criticalCases/$deviceId',
      );
      final snapshot = await criticalCasesRef.get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking if device is critical: $e');
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

  /// Batch update multiple critical cases with transaction
  static Future<void> batchUpdateCriticalCases(
    List<CriticalCase> criticalCases,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{};
      for (final criticalCase in criticalCases) {
        final dataToUpdate = criticalCase.toJson();
        dataToUpdate['lastUpdated'] = ServerValue.timestamp;
        updates['users/$currentUserId/criticalCases/${criticalCase.deviceId}'] =
            dataToUpdate;
      }

      await _database.ref().update(updates);
      print('Batch updated ${criticalCases.length} critical cases');

      // التحقق من نجاح التحديث الجماعي
      for (final criticalCase in criticalCases) {
        final verifyRef = _database.ref(
          'users/$currentUserId/criticalCases/${criticalCase.deviceId}',
        );
        final verifySnapshot = await verifyRef.get();
        if (!verifySnapshot.exists) {
          print(
            'Warning: Critical case ${criticalCase.deviceId} not found after batch update',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to batch update critical cases: $e');
    }
  }

  /// Force sync all critical cases to ensure data consistency
  static Future<void> forceSyncCriticalCases(
    List<CriticalCase> localCases,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      // حذف جميع الحالات الحرجة الموجودة في Firebase
      final criticalCasesRef = _database.ref(
        'users/$currentUserId/criticalCases',
      );
      await criticalCasesRef.remove();

      // إعادة حفظ جميع الحالات المحلية
      final updates = <String, dynamic>{};
      for (final criticalCase in localCases) {
        final dataToSave = criticalCase.toJson();
        dataToSave['lastUpdated'] = ServerValue.timestamp;
        updates['users/$currentUserId/criticalCases/${criticalCase.deviceId}'] =
            dataToSave;
      }

      if (updates.isNotEmpty) {
        await _database.ref().update(updates);
      }

      print('Force synced ${localCases.length} critical cases to Firebase');
    } catch (e) {
      throw Exception('Failed to force sync critical cases: $e');
    }
  }
}
