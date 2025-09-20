import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view/cubit/patient_record_cubit.dart';

class PatientRecordPageController {
  final ScrollController scrollController = ScrollController();

  void dispose() {
    scrollController.dispose();
  }

  // helper to refresh via cubit
  Future<void> refresh(BuildContext context) async {
    try {
      context.read<PatientRecordCubit>().refreshData();
    } catch (_) {}
  }
}
