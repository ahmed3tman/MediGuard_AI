import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../cubit/device_cubit.dart';
import '../../cubit/device_state.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context).addDeviceScreen),
      body: BlocListener<DeviceCubit, DeviceState>(
        listener: (context, state) {
          if (state is DeviceAdded) {
            FloatingSnackBar.showSuccess(
              context,
              message: AppLocalizations.of(context).deviceAddedSuccessfully,
            );
            Navigator.of(context).pop();
          } else if (state is DeviceError) {
            FloatingSnackBar.showError(context, message: state.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header illustration
                  GradientContainer(
                    height: 120,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.primaryColor.withOpacity(0.05),
                    ],
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.medical_services,
                        size: 60,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Device ID field
                  CustomTextField(
                    controller: _deviceIdController,
                    labelText: AppLocalizations.of(context).deviceId,
                    hintText: AppLocalizations.of(context).enterDeviceId,
                    prefixIcon: Icons.qr_code,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).pleaseEnterDeviceId;
                      }
                      if (value.trim().length < 3) {
                        return AppLocalizations.of(context).deviceIdMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Device Name field
                  CustomTextField(
                    controller: _deviceNameController,
                    labelText: AppLocalizations.of(context).deviceName,
                    hintText: AppLocalizations.of(context).enterDeviceName,
                    prefixIcon: Icons.label,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).pleaseEnterDeviceName;
                      }
                      if (value.trim().length < 2) {
                        return AppLocalizations.of(context).deviceNameMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).deviceInfoMessage,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Add button
                  BlocBuilder<DeviceCubit, DeviceState>(
                    builder: (context, state) {
                      final isLoading = state is DeviceAdding;

                      return CustomButton(
                        text: AppLocalizations.of(context).addDevice,
                        onPressed: _addDevice,
                        isLoading: isLoading,
                        width: double.infinity,
                        fontFamily: 'NeoSansArabic',
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addDevice() {
    if (_formKey.currentState!.validate()) {
      final deviceId = _deviceIdController.text.trim();
      final deviceName = _deviceNameController.text.trim();

      context.read<DeviceCubit>().addDevice(deviceId, deviceName);
    }
  }
}
