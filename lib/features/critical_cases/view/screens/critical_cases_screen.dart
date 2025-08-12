import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_cubit.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_state.dart';
import 'package:spider_doctor/features/critical_cases/view/widgets/critical_case_card.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_sync.dart';

class CriticalCasesScreen extends StatelessWidget {
  const CriticalCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.read<CriticalCasesCubit>().loadCriticalCases();
    // لف الشاشة بـ CriticalCasesSync ليتم تحديث الكروت تلقائياً عند تغير الأجهزة
    return CriticalCasesSync.create(
      child: BlocBuilder<CriticalCasesCubit, CriticalCasesState>(
        builder: (context, state) {
          if (state is CriticalCasesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CriticalCasesLoaded) {
            if (state.criticalCases.isEmpty) {
              return _buildEmptyState(l10n);
            }
            return ListView.builder(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: 100,
              ),
              itemCount: state.criticalCases.length,
              itemBuilder: (context, index) {
                final criticalCase = state.criticalCases[index];
                return CriticalCaseCard(
                  criticalCase: criticalCase,
                  isDeleting: false,
                );
              },
            );
          } else if (state is CriticalCaseDeleting) {
            // عرض القائمة مع تفعيل حالة الحذف للعنصر المحدد
            if (state.criticalCases.isEmpty) {
              return _buildEmptyState(l10n);
            }
            return ListView.builder(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: 100,
              ),
              itemCount: state.criticalCases.length,
              itemBuilder: (context, index) {
                final criticalCase = state.criticalCases[index];
                return CriticalCaseCard(
                  criticalCase: criticalCase,
                  isDeleting: criticalCase.deviceId == state.deletingDeviceId,
                );
              },
            );
          } else if (state is CriticalCasesError) {
            return Center(child: Text(state.message));
          }
          return _buildEmptyState(l10n);
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 100,
            color: Color.fromARGB(255, 125, 204, 196),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.allPatientsStable,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.noCriticalCases,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
