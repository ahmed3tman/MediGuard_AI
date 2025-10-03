import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../cubit/device_cubit.dart';
import '../../cubit/device_state.dart';
import '../widgets/device_card.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
    // Devices are now fetched from nested path: users/{uid}/patients/{pid}/device

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
          return Center(
            child: LoadingIndicator(
              message: AppLocalizations.of(context).loadingDevices,
            ),
          );
        }

        if (state is DeviceError) {
          return ErrorStateWidget(
            title: AppLocalizations.of(context).error,
            message: state.message,
            buttonText: AppLocalizations.of(context).retry,
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
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: 100,
              ),

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
            title: AppLocalizations.of(context).noDevicesAdded,
            subtitle: AppLocalizations.of(context).addFirstMedicalDevice,
            icon: Icons.medical_services,
            buttonText: AppLocalizations.of(context).addDemoDevice,
            onButtonPressed: () {
              // Add a demo device for testing
              context.read<DeviceCubit>().addDevice(
                'DEMO001',
                '${AppLocalizations.of(context).demo} Device',
                allowCreatePlaceholder: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
