import 'package:flutter/material.dart';
import '../device_promotion_card.dart';
import '../../navigation/home_navigation_manager.dart';

class DevicePromotionSection extends StatelessWidget {
  final dynamic devicePromotion;

  const DevicePromotionSection({super.key, required this.devicePromotion});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: DevicePromotionCard(
        devicePromotion: devicePromotion,
        onTap: () => HomeNavigationManager.navigateToDeviceDetails(
          context,
          devicePromotion,
        ),
      ),
    );
  }
}
