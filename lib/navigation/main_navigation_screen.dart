import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:spider_doctor/features/home/view/screens/home_screen.dart';
import 'package:spider_doctor/features/profile/view/screens/profile_screen.dart';
import '../features/devices/view/screens/devices_screen.dart';
import '../features/critical_cases/view/screens/critical_cases_screen.dart';
import '../features/devices/bloc/device_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DevicesScreen(),
    const CriticalCasesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceBloc(),
      child: Scaffold(
        body: BottomBar(
          borderRadius: BorderRadius.circular(30),
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate,
          showIcon: true,
          width: MediaQuery.of(context).size.width * 0.9,
          barColor: Colors.transparent,
          start: 2,
          end: 0,
          offset: 0,
          barAlignment: Alignment.bottomCenter,
          iconHeight: 35,
          iconWidth: 35,
          reverse: false,
          hideOnScroll: true,
          scrollOpposite: false,
          onBottomBarHidden: () {},
          onBottomBarShown: () {},
          body: (context, controller) =>
              IndexedStack(index: _currentIndex, children: _screens),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              onTap: _onTabTapped,
              indicator: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.home_outlined, size: 24), text: 'Home'),
                Tab(icon: Icon(Icons.devices, size: 24), text: 'Devices'),
                Tab(
                  icon: Icon(Icons.warning_outlined, size: 24),
                  text: 'Imergency',
                ),
                Tab(
                  icon: Icon(Icons.person_outline, size: 24),
                  text: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
