import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
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
      appBar: CustomAppBar(title: 'Add New Device'),
      body: BlocListener<DeviceCubit, DeviceState>(
        listener: (context, state) {
          if (state is DeviceAdded) {
            FloatingSnackBar.showSuccess(
              context,
              message: 'Device added successfully!',
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
                    labelText: 'Device ID',
                    hintText: 'Enter unique device identifier',
                    prefixIcon: Icons.qr_code,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a device ID';
                      }
                      if (value.trim().length < 3) {
                        return 'Device ID must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Device Name field
                  CustomTextField(
                    controller: _deviceNameController,
                    labelText: 'Device Name',
                    hintText: 'Enter a friendly name for the device',
                    prefixIcon: Icons.label,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a device name';
                      }
                      if (value.trim().length < 2) {
                        return 'Device name must be at least 2 characters';
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
                        const Expanded(
                          child: Text(
                            'Make sure the device ID matches the physical device identifier. This will be used to receive real-time data.',
                            style: TextStyle(fontSize: 13),
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
                        text: 'Add Device',
                        onPressed: _addDevice,
                        isLoading: isLoading,
                        width: double.infinity,
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
