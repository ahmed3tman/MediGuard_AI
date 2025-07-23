import 'package:flutter/material.dart';
import 'package:spider_doctor/features/buy_your_device/cubit/buy_device_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/buy_your_device/view/widgets/buy_device_card.dart';

import 'package:spider_doctor/l10n/generated/app_localizations.dart';

class BuyDeviceScreen extends StatelessWidget {
  const BuyDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.buyDeviceTitle,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'NeoSansArabic',
          ),
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) => BuyDeviceCubit(),
        child: BlocBuilder<BuyDeviceCubit, BuyDeviceState>(
          builder: (context, state) {
            if (state is BuyDeviceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BuyDeviceSuccess) {
              return _buildSuccessState(l10n);
            } else if (state is BuyDeviceError) {
              return _buildErrorState(state.message, l10n);
            }
            return BuyDeviceCard(l10n: l10n);
          },
        ),
      ),
    );
  }

  // تم نقل ودجت البيع إلى ملف منفصل BuyDeviceCard

  Widget _buildSuccessState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              l10n.buyDeviceSuccess,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
       
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          Text(
            l10n.buyDeviceError,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
