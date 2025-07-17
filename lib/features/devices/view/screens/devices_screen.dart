import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../cubit/device_cubit.dart';
import '../../cubit/device_state.dart';
import '../widgets/device_card.dart';
import '../../../auth/services/auth_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Load devices when screen opens, but only if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.isSignedIn) {
        context.read<DeviceCubit>().loadDevices();
      }
    });

    // Listen to auth state changes
    _authSubscription = AuthService.authStateChanges.listen((user) {
      if (user != null && mounted) {
        context.read<DeviceCubit>().loadDevices();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        if (state is DeviceLoading) {
          return const Center(
            child: LoadingIndicator(message: 'Loading devices...'),
          );
        }

        if (state is DeviceError) {
          return ErrorStateWidget(
            title: 'Error',
            message: state.message,
            buttonText: 'Retry',
            onButtonPressed: () {
              context.read<DeviceCubit>().loadDevices();
            },
          );
        }

        if (state is DeviceLoaded) {
          if (state.devices.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DeviceCubit>().loadDevices();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                return DeviceCard(device: state.devices[index]);
              },
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: EmptyStateWidget(
            title: 'No Devices Added',
            subtitle:
                'Add your first medical device to start monitoring vital signs in real-time.',
            icon: Icons.medical_services,
            buttonText: 'Add Demo Device',
            onButtonPressed: () {
              // Add a demo device for testing
              context.read<DeviceCubit>().addDevice('DEMO001', 'Demo Device');
            },
          ),
        ),
      ],
    );
  }
}
