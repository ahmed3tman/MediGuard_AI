import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/model/patient_vital_signs.dart';

class EcgSection extends StatelessWidget {
  final List<EcgReading> ecgReadings;
  final PatientVitalSigns vitalSigns;
  final AppLocalizations l10n;

  const EcgSection({
    super.key,
    required this.ecgReadings,
    required this.vitalSigns,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
                    Expanded(
                      child: EcgChart(readings: ecgReadings, l10n: l10n),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class EcgChart extends StatelessWidget {
  final List<EcgReading> readings;
  final AppLocalizations l10n;

  const EcgChart({super.key, required this.readings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Text(
          l10n.noEcgData,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }
    final spots = readings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
    final values = readings.map((e) => e.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxValue - minValue) * 0.1;
    final minY = minValue - padding;
    final maxY = maxValue + padding;
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
}
