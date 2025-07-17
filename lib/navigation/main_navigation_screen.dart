import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:spider_doctor/core/shared/theme/my_colors.dart';
import 'package:spider_doctor/core/shared/widgets/app_drawer.dart';
import 'package:spider_doctor/features/home/view/screens/home_screen.dart';
import '../features/devices/view/screens/devices_screen.dart';
import '../features/devices/view/screens/add_device_screen.dart';
import '../features/critical_cases/view/screens/critical_cases_screen.dart';
import '../features/profile/view/screens/profile_screen.dart';
import '../features/devices/cubit/device_cubit.dart';
import '../features/home/cubit/home_cubit.dart';
import '../features/profile/cubit/profile_cubit.dart';
import '../features/critical_cases/cubit/critical_cases_cubit.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DevicesScreen(),
    const CriticalCasesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animateTo(_currentIndex);
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

  AppBar _buildAppBar(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return AppBar(
          title: const Text('Home'),
          centerTitle: true,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
      case 1:
        return AppBar(
          title: const Text('Real Time Monitoring'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                print('Add Device button pressed'); // Debug print
                final deviceCubit = context.read<DeviceCubit>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: deviceCubit,
                      child: const AddDeviceScreen(),
                    ),
                  ),
                );
              },
              tooltip: 'Add Device',
            ),
          ],
        );
      case 2:
        return AppBar(
          title: const Text('Critical Cases'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
      case 3:
        return AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
      default:
        return AppBar(
          title: const Text('Spider Doctor'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DeviceCubit()),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => CriticalCasesCubit()),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: _buildAppBar(context),
          drawer: const AppDrawer(),
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
                color: AppColors.primaryColor,
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
      ),
    );
  }
}
