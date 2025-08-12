import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_cubit.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_state.dart';

/// Widget لعرض حالة مزامنة البيانات مع Firebase
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CriticalCasesCubit, CriticalCasesState>(
      builder: (context, state) {
        final cubit = context.read<CriticalCasesCubit>();
        final dataStatus = cubit.getDataStatus();

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'حالة المزامنة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // عرض عدد الحالات المحلية
                _buildInfoRow(
                  'عدد الحالات المحلية',
                  '${dataStatus['localCasesCount']}',
                  Icons.storage,
                ),

                // عرض آخر تحديث
                if (dataStatus['lastLocalUpdate'] != null)
                  _buildInfoRow(
                    'آخر تحديث',
                    _formatDateTime(dataStatus['lastLocalUpdate']),
                    Icons.schedule,
                  ),

                const SizedBox(height: 16),

                // أزرار التحكم
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state is CriticalCasesLoading
                            ? null
                            : () {
                                _syncToFirebase(context, cubit);
                              },
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('رفع للخادم'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state is CriticalCasesLoading
                            ? null
                            : () {
                                _resyncFromFirebase(context, cubit);
                              },
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('تحديث من الخادم'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // زر التحقق من التطابق
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state is CriticalCasesLoading
                        ? null
                        : () {
                            _verifyConsistency(context, cubit);
                          },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('التحقق من تطابق البيانات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                // مؤشر التحميل
                if (state is CriticalCasesLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'منذ لحظات';
      } else if (difference.inHours < 1) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inDays < 1) {
        return 'منذ ${difference.inHours} ساعة';
      } else {
        return 'منذ ${difference.inDays} يوم';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }

  void _syncToFirebase(BuildContext context, CriticalCasesCubit cubit) async {
    try {
      await cubit.syncToFirebase();
      _showSuccessMessage(context, 'تم رفع البيانات للخادم بنجاح');
    } catch (e) {
      _showErrorMessage(context, 'فشل في رفع البيانات: ${e.toString()}');
    }
  }

  void _resyncFromFirebase(
    BuildContext context,
    CriticalCasesCubit cubit,
  ) async {
    try {
      await cubit.forceResyncFromFirebase();
      _showSuccessMessage(context, 'تم تحديث البيانات من الخادم بنجاح');
    } catch (e) {
      _showErrorMessage(context, 'فشل في التحديث: ${e.toString()}');
    }
  }

  void _verifyConsistency(
    BuildContext context,
    CriticalCasesCubit cubit,
  ) async {
    try {
      final isConsistent = await cubit.verifyDataConsistency();
      if (isConsistent) {
        _showSuccessMessage(context, 'البيانات متطابقة مع الخادم');
      } else {
        _showWarningMessage(
          context,
          'البيانات غير متطابقة، يُنصح بإعادة المزامنة',
        );
      }
    } catch (e) {
      _showErrorMessage(context, 'فشل في التحقق: ${e.toString()}');
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
