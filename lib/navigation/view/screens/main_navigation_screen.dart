// استيراد المكتبات المطلوبة
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// استيراد الثيمات والويدجتس المشتركة
import 'package:spider_doctor/core/shared/theme/my_colors.dart';
import 'package:spider_doctor/core/shared/widgets/app_drawer.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';

// استيراد صفحات التطبيق
import 'package:spider_doctor/features/home/view/screens/home_screen.dart';
import '../../../features/devices/view/screens/devices_screen.dart';
import '../../../features/add_device/view/screens/add_device_screen.dart';
import '../../../features/critical_cases/view/screens/critical_cases_screen.dart';
import '../../../features/profile/view/screens/profile_screen.dart';

// استيراد الـ Cubits لإدارة الحالة
import '../../../features/devices/cubit/device_cubit.dart';
import '../../../features/home/cubit/home_cubit.dart';
import '../../../features/profile/cubit/profile_cubit.dart';
import '../../../features/critical_cases/cubit/critical_cases_cubit.dart';
import '../../../features/critical_cases/cubit/critical_cases_state.dart';

// كلاس الشاشة الرئيسية للتنقل - يحتوي على البوتوم نافيجيشن بار
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex; // الفهرس الأولي للتاب المحدد

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  // متحكم التابز للتنقل بين الصفحات
  late TabController _tabController;

  // الفهرس الحالي للتاب النشط
  late int _currentIndex;

  // حالة إظهار أو إخفاء البوتوم بار
  bool _isBottomBarVisible = true;

  // تايمر لإظهار البار تلقائياً بعد فترة من عدم الحركة
  Timer? _hideTimer;

  // مسافة الاسكرول لأسفل لحساب متى يختفي البار
  double _scrollDistance = 0.0;

  // مسافة الاسكرول لأعلى لحساب متى يظهر البار
  double _upScrollDistance = 0.0;

  // قائمة الصفحات المختلفة في التطبيق
  final List<Widget> _screens = [
    const HomeScreen(),
    const DevicesScreen(),
    const CriticalCasesScreen(),
    const ProfileScreen(),
  ];

  // تهيئة الشاشة عند البدء
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animateTo(_currentIndex);
    _setupScrollListener();
  }

  // إعداد مستمع الاسكرول (غير مستخدم حالياً)
  void _setupScrollListener() {
    // لا نحتاج لمستمع الاسكرول هنا
    // سنستخدم NotificationListener بدلاً من ذلك
  }

  // تنظيف الموارد عند إغلاق الشاشة
  @override
  void dispose() {
    _tabController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  // دالة التعامل مع الضغط على تابات البوتوم بار
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  // دالة إنشاء الآب بار حسب الصفحة الحالية
  AppBar _buildAppBar(BuildContext context) {
    switch (_currentIndex) {
      case 0: // صفحة الهوم
        return AppBar(
          title: Text(
            AppLocalizations.of(context).home,
            style: const TextStyle(
              fontFamily: 'NeoSansArabic',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
      case 1: // صفحة الأجهزة
        return AppBar(
          title: Text(
            AppLocalizations.of(context).realTimeMonitoring,
            style: const TextStyle(
              fontFamily: 'NeoSansArabic',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                print('Add Device button pressed');
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
              tooltip: AppLocalizations.of(context).addDeviceTooltip,
            ),
          ],
        );
      case 2: // صفحة الحالات الحرجة
        return AppBar(
          title: Text(
            AppLocalizations.of(context).criticalCases,
            style: const TextStyle(
              fontFamily: 'NeoSansArabic',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
      case 3: // صفحة الملف الشخصي
        return AppBar(
          title: Text(
            AppLocalizations.of(context).profile,
            style: const TextStyle(
              fontFamily: 'NeoSansArabic',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
      default:
        return AppBar(
          title: Text(
            AppLocalizations.of(context).appTitle,
            style: const TextStyle(
              fontFamily: 'NeoSansArabic',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        );
    }
  }

  // بناء واجهة المستخدم الرئيسية
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // توفير جميع الـ Cubits للصفحات المختلفة
      providers: [
        BlocProvider(create: (context) => DeviceCubit()),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider<CriticalCasesCubit>(
          create: (context) => CriticalCasesCubit(),
          lazy: false,
        ),
      ],
      child: Builder(
        builder: (context) {
          // استدعاء `loadCriticalCases` عند بناء الواجهة
          // للتأكد من تحديث البيانات عند عرض الشاشة
          context.read<CriticalCasesCubit>().loadCriticalCases();

          return Scaffold(
            appBar: _buildAppBar(context),
            drawer: const AppDrawer(),
            body: Stack(
              children: [
                // المحتوى الرئيسي مع مراقبة الاسكرول
                Positioned.fill(
                  child: NotificationListener<ScrollNotification>(
                    // مستمع الاسكرول للتحكم في إظهار/إخفاء البوتوم بار
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo is ScrollUpdateNotification) {
                        // التحقق من وجود حركة اسكرول عمودية فقط وليس أفقية
                        if (scrollInfo.scrollDelta != null &&
                            scrollInfo.metrics.axis == Axis.vertical &&
                            scrollInfo.metrics.pixels >= 0 &&
                            scrollInfo.metrics.pixels <=
                                scrollInfo.metrics.maxScrollExtent &&
                            !scrollInfo.metrics.outOfRange) {
                          // تحديث مسافة الاسكرول حسب الاتجاه
                          if (scrollInfo.scrollDelta! > 0) {
                            // الاسكرول لأسفل - تجميع المسافة
                            _scrollDistance += scrollInfo.scrollDelta!;
                            _upScrollDistance =
                                0.0; // إعادة تعيين مسافة الاسكرول لأعلى

                            // إخفاء البوتوم بار إذا تم الاسكرول لأسفل بما فيه الكفاية
                            if (_scrollDistance > 200 && _isBottomBarVisible) {
                              setState(() {
                                _isBottomBarVisible = false;
                              });
                            }

                            // إلغاء أي تايمر موجود
                            _hideTimer?.cancel();

                            // تعيين تايمر لإظهار البوتوم بار بعد 3 ثوان من عدم الاسكرول
                            _hideTimer = Timer(const Duration(seconds: 3), () {
                              if (mounted && !_isBottomBarVisible) {
                                setState(() {
                                  _isBottomBarVisible = true;
                                  _scrollDistance = 0.0; // إعادة تعيين المسافة
                                });
                              }
                            });
                          } else if (scrollInfo.scrollDelta! < 0) {
                            // الاسكرول لأعلى - تجميع مسافة الاسكرول لأعلى
                            _upScrollDistance += scrollInfo.scrollDelta!
                                .abs(); // إضافة القيمة المطلقة

                            // إظهار البوتوم بار إذا تم الاسكرول لأعلى بما فيه الكفاية
                            if (_upScrollDistance > 50 &&
                                !_isBottomBarVisible) {
                              setState(() {
                                _isBottomBarVisible = true;
                              });
                              _upScrollDistance =
                                  0.0; // إعادة تعيين مسافة الاسكرول لأعلى
                            }

                            _scrollDistance =
                                0.0; // إعادة تعيين مسافة الاسكرول لأسفل عند الاسكرول لأعلى

                            // إلغاء التايمر لأن المستخدم يتفاعل بالاسكرول
                            _hideTimer?.cancel();
                          }
                        }
                      }
                      return false;
                    },
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
                  ),
                ),

                // البوتوم نافيجيشن بار
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: _isBottomBarVisible
                      ? 30
                      : -100, // إظهار أو إخفاء البار
                  left: MediaQuery.of(context).size.width * 0.04,
                  right: MediaQuery.of(context).size.width * 0.04,
                  child: Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorSize: TabBarIndicatorSize.tab,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NeoSansArabic',
                        color: Colors.white,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'NeoSansArabic',
                        color: Colors.white70,
                      ),
                      // تابات البوتوم بار
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.home_outlined, size: 22),
                          text: AppLocalizations.of(context).home,
                        ),
                        Tab(
                          icon: const Icon(Icons.devices, size: 22),
                          text: AppLocalizations.of(context).devices,
                        ),
                        // استخدام BlocBuilder للاستماع لتغيرات عدد الحالات الحرجة
                        BlocBuilder<CriticalCasesCubit, CriticalCasesState>(
                          builder: (context, state) {
                            final criticalCasesCount =
                                state is CriticalCasesLoaded
                                ? state.criticalCases.length
                                : 0;

                            return Tab(
                              icon: Badge(
                                // تحديد لون خلفية الشارة
                                backgroundColor: Colors.orange,
                                // عرض العدد إذا كان أكبر من صفر
                                label: Text(criticalCasesCount.toString()),
                                // إخفاء الشارة إذا كان العدد صفرًا
                                isLabelVisible: criticalCasesCount > 0,
                                child: const Icon(
                                  Icons.warning_outlined,
                                  size: 20,
                                ),
                              ),
                              text: AppLocalizations.of(context).criticalCases,
                            );
                          },
                        ),
                        Tab(
                          icon: const Icon(Icons.person_outline, size: 20),
                          text: AppLocalizations.of(context).profile,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
