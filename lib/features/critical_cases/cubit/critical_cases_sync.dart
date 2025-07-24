import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_cubit.dart';
import 'package:spider_doctor/features/devices/cubit/device_cubit.dart';
import 'package:spider_doctor/features/devices/cubit/device_state.dart';

/// Helper to sync critical cases with device updates
class CriticalCasesSync {
  static BlocListener<DeviceCubit, DeviceState> create({
    required Widget child,
  }) {
    return BlocListener<DeviceCubit, DeviceState>(
      listener: (context, deviceState) {
        if (deviceState is DeviceLoaded) {
          final devices = deviceState.devices;
          final criticalCasesCubit = context.read<CriticalCasesCubit>();
          criticalCasesCubit.updateCriticalCasesFromDevices(devices);
        }
      },
      child: child,
    );
  }
}
