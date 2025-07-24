import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      builder: (context, state) {
        if (state is! PatientDetailLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.initializingPatientMonitoring),
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
                _buildPatientHeader(vitalSigns, l10n),
                const SizedBox(height: 20),

                // Vital Signs Grid
                _buildVitalSignsGrid(vitalSigns, l10n),

                // ECG Chart Section
                _buildEcgSection(ecgReadings, vitalSigns, l10n),
                const SizedBox(height: 30),

                // Controls
                _buildControlsSection(l10n),
                const SizedBox(height: 40), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientHeader(
    PatientVitalSigns vitalSigns,
    AppLocalizations l10n,
  ) {
    final isLive =
        vitalSigns.heartRate > 0 ||
        vitalSigns.temperature > 0 ||
        vitalSigns.spo2 > 0 ||
        _isBloodPressureConnected(vitalSigns.bloodPressure);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85), // ⬅️ أبيض شفاف
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2), // ⬅️ بوردر ناعم أزرق شفاف
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08), // ⬅️ ظل خفيف
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vitalSigns.patientName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.deviceIdLabel}${vitalSigns.deviceId}',
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 14,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.lastUpdatedLabel}${_formatTime(vitalSigns.timestamp, l10n)}',
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLive ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi,
                  color: isLive ? Colors.green[800] : Colors.red[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isLive ? l10n.liveStatus : l10n.offlineStatus,
                  style: TextStyle(
                    color: isLive ? Colors.green[800] : Colors.red[700],
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

  Widget _buildVitalSignsGrid(
    PatientVitalSigns vitalSigns,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vitalSignsTitle,
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
          childAspectRatio: 1.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildVitalSignCard(
              title: l10n.temperature,
              value: _getTemperatureDisplay(vitalSigns.temperature, l10n),
              unit: vitalSigns.temperature > 0 ? '°C' : '',
              icon: Icons.thermostat,
              color: Colors.deepOrange.shade300,
              isConnected: vitalSigns.temperature > 0,
            ),
            _buildVitalSignCard(
              title: l10n.heartRate,
              value: _getHeartRateDisplay(vitalSigns.heartRate, l10n),
              unit: vitalSigns.heartRate > 0 ? 'BPM' : '',
              icon: Icons.favorite,
              color: Colors.red.shade300,
              isConnected: vitalSigns.heartRate > 0,
            ),
            _buildVitalSignCard(
              title: l10n.bloodPressure,
              value: _getBloodPressureDisplay(vitalSigns.bloodPressure, l10n),
              unit: _isBloodPressureConnected(vitalSigns.bloodPressure)
                  ? 'mmHg'
                  : '',
              icon: Icons.monitor_heart,
              color: Colors.indigo.shade300,
              isConnected: _isBloodPressureConnected(vitalSigns.bloodPressure),
            ),
            _buildVitalSignCard(
              title: l10n.spo2,
              value: _getSpo2Display(vitalSigns.spo2, l10n),
              unit: vitalSigns.spo2 > 0 ? '%' : '',
              icon: Icons.air,
              color: Colors.cyan.shade400,
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected ? color.withOpacity(0.3) : Colors.grey[300]!,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // مهم علشان ياخد أقل ارتفاع ممكن
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isConnected
                      ? color.withOpacity(0.10)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isConnected ? color : Colors.grey[400],
                  size: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 9,
                      color: isConnected ? Colors.green[700] : Colors.grey[500],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      isConnected
                          ? l10n.connectedStatus
                          : l10n.offlineStatusSmall,
                      style: TextStyle(
                        fontSize: 8,
                        color: isConnected
                            ? Colors.green[700]
                            : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          if (isConnected) ...[
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.ecgMonitorTitle,
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
                    ecgReadings.isNotEmpty
                        ? l10n.ecgConnectedStatus
                        : l10n.ecgNotConnectedStatus,
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
                        l10n.ecgDeviceNotConnectedError,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.ecgDeviceNotConnectedHint,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Text(
                      l10n.ecgChartTitle(
                        ecgReadings.length.toString(),
                        vitalSigns.heartRate.toInt().toString(),
                      ),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildEcgChart(ecgReadings, l10n)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEcgChart(List<EcgReading> readings, AppLocalizations l10n) {
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
          l10n.noEcgData,
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
                    l10n.ecgTooltip(
                      flSpot.y.toStringAsFixed(2),
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                    ),
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

  Widget _buildControlsSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
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
            l10n.monitoringControlsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'NeoSansArabic',
            ),
          ),
          // const SizedBox(height: 12),
          // Row(
          //   children: [
          //     Expanded(
          //       child: ElevatedButton.icon(
          //         onPressed: () =>
          //             context.read<PatientDetailCubit>().refreshData(),
          //         icon: const Icon(Icons.refresh),
          //         label: const Text('Refresh Data'),
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.blue[600],
          //           foregroundColor: Colors.white,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: ElevatedButton.icon(
          //         onPressed: () =>
          //             context.read<PatientDetailCubit>().cleanupOldData(),
          //         icon: const Icon(Icons.cleaning_services),
          //         label: const Text('Cleanup Data'),
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.blue[600],
          //           foregroundColor: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 8),
          Text(
            l10n.monitoringControlsDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return l10n.timeJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeMinutesAgo(difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return l10n.timeHoursAgo(difference.inHours.toString());
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Helper methods for accurate data display
  String _getTemperatureDisplay(double temperature, AppLocalizations l10n) {
    if (temperature <= 0) {
      return l10n.deviceNotConnected;
    }
    return temperature.toStringAsFixed(1);
  }

  String _getHeartRateDisplay(double heartRate, AppLocalizations l10n) {
    if (heartRate <= 0) {
      return l10n.deviceNotConnected;
    }
    return heartRate.toStringAsFixed(0);
  }

  String _getBloodPressureDisplay(
    Map<String, dynamic> bloodPressure,
    AppLocalizations l10n,
  ) {
    final systolic = bloodPressure['systolic'] ?? 0;
    final diastolic = bloodPressure['diastolic'] ?? 0;

    if (systolic <= 0 || diastolic <= 0) {
      return l10n.deviceNotConnected;
    }
    return '$systolic/$diastolic';
  }

  bool _isBloodPressureConnected(Map<String, dynamic> bloodPressure) {
    final systolic = bloodPressure['systolic'] ?? 0;
    final diastolic = bloodPressure['diastolic'] ?? 0;
    return systolic > 0 && diastolic > 0;
  }

  String _getSpo2Display(double spo2, AppLocalizations l10n) {
    if (spo2 <= 0) {
      return l10n.deviceNotConnected;
    }
    return spo2.toStringAsFixed(0);
  }
}
