import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../edit_patient_info/cubit/patient_info_cubit.dart';
import '../../../edit_patient_info/cubit/patient_info_state.dart';
import '../../../../core/shared/widgets/widgets.dart';

class AddDeviceSubmitButton extends StatelessWidget {
  const AddDeviceSubmitButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientInfoCubit, PatientInfoState>(
      builder: (ctx, patientState) {
        final isPatientLoading = patientState is PatientInfoSaving;
        return CustomButton(
          text: AppLocalizations.of(ctx).addDeviceAndPatient,
          onPressed: onPressed,
          isLoading: isPatientLoading,
          width: double.infinity,
          fontFamily: 'NeoSansArabic',
          fontWeight: FontWeight.bold,
        );
      },
    );
  }
}
