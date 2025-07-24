import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/buy_your_device/cubit/buy_device_cubit.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';

class BuyDeviceCard extends StatefulWidget {
  final AppLocalizations l10n;
  const BuyDeviceCard({super.key, required this.l10n});

  @override
  State<BuyDeviceCard> createState() => BuyDeviceCardState();
}

class BuyDeviceCardState extends State<BuyDeviceCard> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String address = '';

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return SingleChildScrollView(
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 160,
      
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/device.png'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.buyDeviceTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.buyDeviceDesc,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? l10n.fullNameRequired
                      : null,
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? l10n.phoneNumberRequired
                      : null,
                  onSaved: (value) => phone = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? l10n.addressRequired
                      : null,
                  onSaved: (value) => address = value ?? '',
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        BlocProvider.of<BuyDeviceCubit>(context).buyDevice();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAD3B6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.sendOrder,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NeoSansArabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
