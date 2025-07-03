import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/device_bloc.dart';
import '../../bloc/device_event.dart';
import '../../bloc/device_state.dart';

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
      appBar: AppBar(
        title: const Text('Add New Device'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Device added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is DeviceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header illustration
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                // Device ID field
                TextFormField(
                  controller: _deviceIdController,
                  decoration: const InputDecoration(
                    labelText: 'Device ID',
                    hintText: 'Enter unique device identifier',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
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
                TextFormField(
                  controller: _deviceNameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name',
                    hintText: 'Enter a friendly name for the device',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
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
                BlocBuilder<DeviceBloc, DeviceState>(
                  builder: (context, state) {
                    final isLoading = state is DeviceAdding;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _addDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Adding Device...'),
                              ],
                            )
                          : const Text(
                              'Add Device',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ],
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

      context.read<DeviceBloc>().add(AddDevice(deviceId, deviceName));
    }
  }
}
