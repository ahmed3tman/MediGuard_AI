import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/patient_detail_cubit.dart';
import '../../cubit/patient_detail_state.dart';
import '../../model/data_model.dart';
import '../widgets/patient_detail_doctor_tab.dart';

/// Main patient detail screen with tabbed interface
class PatientDetailScreen extends StatefulWidget {
  final Device device;

  const PatientDetailScreen({super.key, required this.device});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientDetailCubit(
        deviceId: widget.device.deviceId,
        patientName: widget.device.name,
      )..initialize(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(widget.device.name),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.local_hospital),
                text: 'Doctor', // Primary medical view
              ),
              Tab(
                icon: const Icon(Icons.analytics),
                text: 'Analytics', // Historical data and trends
              ),
              Tab(
                icon: const Icon(Icons.settings),
                text: 'Settings', // Device settings and calibration
              ),
            ],
          ),
        ),
        body: BlocBuilder<PatientDetailCubit, PatientDetailState>(
          builder: (context, state) {
            if (state is PatientDetailLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading patient data...'),
                  ],
                ),
              );
            } else if (state is PatientDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PatientDetailCubit>().initialize(),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Doctor Tab - Main medical monitoring view
                const PatientDetailDoctorTab(),

                // Analytics Tab - Coming soon
                _buildComingSoonTab(
                  icon: Icons.analytics,
                  title: 'Analytics & Trends',
                  description: 'Historical data analysis and patient trends',
                ),

                // Settings Tab - Coming soon
                _buildComingSoonTab(
                  icon: Icons.settings,
                  title: 'Device Settings',
                  description: 'Device configuration and calibration options',
                ),
              ],
            );
          },
        ),
        floatingActionButton:
            BlocBuilder<PatientDetailCubit, PatientDetailState>(
              builder: (context, state) {
                if (state is PatientDetailLoaded) {
                  return FloatingActionButton(
                    onPressed: () =>
                        context.read<PatientDetailCubit>().refreshData(),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.refresh),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }

  Widget _buildComingSoonTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Coming Soon',
                style: TextStyle(
                  color: Colors.amber[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
