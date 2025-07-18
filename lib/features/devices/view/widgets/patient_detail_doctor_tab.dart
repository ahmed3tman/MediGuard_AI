import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../cubit/patient_detail_cubit.dart';
// ...existing imports...
import '../../cubit/patient_detail_state.dart';
import '../../model/patient_vital_signs.dart';

/// Doctor tab showing real-time vital signs and ECG chart
class PatientDetailDoctorTab extends StatefulWidget {
  const PatientDetailDoctorTab({super.key});

  @override
  State<PatientDetailDoctorTab> createState() => _PatientDetailDoctorTabState();
}

class _PatientDetailDoctorTabState extends State<PatientDetailDoctorTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      builder: (context, state) {
        if (state is! PatientDetailLoaded) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing patient monitoring...'),
              ],
            ),
          );
        }

        final vitalSigns = state.vitalSigns;
        final ecgReadings = state.ecgReadings;

        // Debug information
        print('ECG Readings in build: ${ecgReadings.length}');
        print(
          'Vital Signs: Temperature=${vitalSigns.temperature}, HR=${vitalSigns.heartRate}',
        );
        if (ecgReadings.isNotEmpty) {
          print(
            'First ECG reading: ${ecgReadings.first.value} at ${ecgReadings.first.timestamp}',
          );
          print(
            'Last ECG reading: ${ecgReadings.last.value} at ${ecgReadings.last.timestamp}',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<PatientDetailCubit>().refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Info Header
                _buildPatientHeader(vitalSigns),
                const SizedBox(height: 20),

                // Vital Signs Grid
                _buildVitalSignsGrid(vitalSigns),
                const SizedBox(height: 24),

                // ECG Chart Section
                _buildEcgSection(ecgReadings, vitalSigns),
                const SizedBox(height: 20),

                // Controls
                _buildControlsSection(),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientHeader(PatientVitalSigns vitalSigns) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 32, color: Colors.blue[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vitalSigns.patientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Device ID: ${vitalSigns.deviceId}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Updated: ${_formatTime(vitalSigns.timestamp)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[500],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsGrid(PatientVitalSigns vitalSigns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vital Signs',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildVitalSignCard(
              title: 'Temperature',
              value: vitalSigns.temperature > 0
                  ? vitalSigns.temperature.toStringAsFixed(1)
                  : '--',
              unit: '°C',
              icon: Icons.thermostat,
              color: Colors.orange,
              isConnected: vitalSigns.temperature > 0,
            ),
            _buildVitalSignCard(
              title: 'Heart Rate',
              value: vitalSigns.heartRate > 0
                  ? vitalSigns.heartRate.toStringAsFixed(0)
                  : '--',
              unit: 'BPM',
              icon: Icons.favorite,
              color: Colors.red,
              isConnected: vitalSigns.heartRate > 0,
            ),
            _buildVitalSignCard(
              title: 'Blood Pressure',
              value:
                  (vitalSigns.bloodPressure['systolic'] ?? 0) > 0 &&
                      (vitalSigns.bloodPressure['diastolic'] ?? 0) > 0
                  ? '${vitalSigns.bloodPressure['systolic']}/${vitalSigns.bloodPressure['diastolic']}'
                  : '--/--',
              unit: 'mmHg',
              icon: Icons.monitor_heart,
              color: Colors.purple,
              isConnected:
                  (vitalSigns.bloodPressure['systolic'] ?? 0) > 0 &&
                  (vitalSigns.bloodPressure['diastolic'] ?? 0) > 0,
            ),
            _buildVitalSignCard(
              title: 'SpO₂',
              value: vitalSigns.spo2 > 0
                  ? vitalSigns.spo2.toStringAsFixed(0)
                  : '--',
              unit: '%',
              icon: Icons.air,
              color: Colors.blue,
              isConnected: vitalSigns.spo2 > 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalSignCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    bool isConnected = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? color.withOpacity(0.3) : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConnected
                      ? color.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isConnected ? color : Colors.grey[500],
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isConnected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 10,
                  color: isConnected ? Colors.green[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (isConnected) ...[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Not Connected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEcgSection(
    List<EcgReading> ecgReadings,
    PatientVitalSigns vitalSigns,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ECG Monitor',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ecgReadings.isNotEmpty
                    ? Colors.green[100]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ecgReadings.isNotEmpty
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 12,
                    color: ecgReadings.isNotEmpty
                        ? Colors.green[700]
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ecgReadings.isNotEmpty ? 'CONNECTED' : 'NOT CONNECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ecgReadings.isNotEmpty
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[300]!, width: 2),
          ),
          child: ecgReadings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monitor_heart,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No ECG data available (${ecgReadings.length} readings)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ECG requires active heart rate monitoring',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Text(
                      'ECG Chart - ${ecgReadings.length} readings (HR: ${vitalSigns.heartRate.toInt()} BPM)',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildEcgChart(ecgReadings)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEcgChart(List<EcgReading> readings) {
    // Debug print to check if we have data
    print('ECG Readings count: ${readings.length}');
    if (readings.isNotEmpty) {
      print(
        'First reading: ${readings.first.value} at ${readings.first.timestamp}',
      );
    }

    if (readings.isEmpty) {
      return Center(
        child: Text(
          'No ECG data available',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    // Convert ECG readings to chart data points
    final spots = readings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    print('Chart spots count: ${spots.length}');

    // Calculate dynamic Y-axis range for better visualization
    final values = readings.map((e) => e.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxValue - minValue) * 0.1; // 10% padding
    final minY = minValue - padding;
    final maxY = maxValue + padding;

    print('Y-axis range: $minY to $maxY');

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: (maxY - minY) / 6,
          verticalInterval: spots.length > 20 ? spots.length / 8 : 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.blue[200]!.withOpacity(0.4),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.blue[200]!.withOpacity(0.4),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: spots.length > 15 ? spots.length / 6 : 3,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < readings.length && value.toInt() >= 0) {
                  final reading = readings[value.toInt()];
                  final time = reading.timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.blue[300]!, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.red[600],
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.red[600]!.withOpacity(0.3),
                  Colors.red[600]!.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                if (flSpot.x.toInt() < readings.length &&
                    flSpot.x.toInt() >= 0) {
                  final reading = readings[flSpot.x.toInt()];
                  final time = reading.timestamp;
                  return LineTooltipItem(
                    'ECG: ${flSpot.y.toStringAsFixed(2)} mV\n${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                    TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        minX: 0,
        maxX: readings.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monitoring Controls',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<PatientDetailCubit>().refreshData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<PatientDetailCubit>().cleanupOldData(),
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Cleanup Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Real-time data updates every 2 seconds\n'
            '• ECG shows last 50 readings\n'
            '• All vital signs are monitored continuously\n'
            '• Abnormal values are highlighted in red',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
