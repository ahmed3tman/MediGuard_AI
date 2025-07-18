import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).home,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Demo of localized strings
            // Card(
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Localization Demo:',
            //           style: Theme.of(context).textTheme.headlineSmall,
            //         ),
            //         const SizedBox(height: 10),
            //         Text(AppLocalizations.of(context).realTimeMonitoring),
            //         Text(AppLocalizations.of(context).waitingForDeviceData),
            //         Text(AppLocalizations.of(context).temperature),
            //         Text(AppLocalizations.of(context).tellMeYourQuestion),
            //         Text(AppLocalizations.of(context).heartRate),
            //         Text(AppLocalizations.of(context).bloodPressure),
            //         Text(AppLocalizations.of(context).oxygenSaturation),
            //         const SizedBox(height: 10),
            //         Text(
            //           '${AppLocalizations.of(context).connected} / ${AppLocalizations.of(context).disconnected}',
            //         ),
            //         Text(
            //           '${AppLocalizations.of(context).normal} / ${AppLocalizations.of(context).abnormal}',
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
