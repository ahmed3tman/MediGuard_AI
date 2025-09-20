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
    // Detect if there is any non-zero signal in the provided readings
    final bool hasAnySamples = ecgReadings.isNotEmpty;
    final bool hasSignal = ecgReadings.any((r) => r.value.abs() > 1e-6);
    final bool isActuallyConnected =
        vitalSigns.isActuallyConnected && hasSignal;

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
                color: isActuallyConnected
                    ? Colors.green[100]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActuallyConnected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 12,
                    color: isActuallyConnected
                        ? Colors.green[700]
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActuallyConnected
                        ? l10n.ecgConnectedStatus
                        : l10n.ecgNotConnectedStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActuallyConnected
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
          child: (!hasAnySamples || !hasSignal)
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
                      if (!vitalSigns.isActuallyConnected)
                        Text(
                          l10n.ecgDeviceNotConnectedError,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          l10n.noEcgDataAvailable,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (!vitalSigns.isActuallyConnected)
                        Text(
                          l10n.ecgDeviceNotConnectedHint,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
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
    // Time-based sliding window to create a continuous scrolling waveform
    const int windowSeconds =
        10; // narrower window to spread the waveform horizontally
    final int lastMillis = readings.last.timestamp.millisecondsSinceEpoch;
    final int fromMillis = lastMillis - (windowSeconds * 1000);
    final List<EcgReading> window = readings
        .where((r) => r.timestamp.millisecondsSinceEpoch >= fromMillis)
        .toList(growable: false);

    // Map timestamps to a relative 0..windowSeconds domain for stable axis
    final double lastSec = lastMillis / 1000.0;
    final double startSec = lastSec - windowSeconds;

    final spots = window.map((r) {
      final double t = r.timestamp.millisecondsSinceEpoch / 1000.0;
      return FlSpot((t - startSec).clamp(0, windowSeconds).toDouble(), r.value);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

    final values = window.isNotEmpty
        ? window.map((e) => e.value).toList()
        : [0.0, 1.0];
    double minValue = values.reduce((a, b) => a < b ? a : b);
    double maxValue = values.reduce((a, b) => a > b ? a : b);
    if (minValue == maxValue) {
      // Avoid a flat range which can cause zero intervals
      minValue -= 1.0;
      maxValue += 1.0;
    }
    final padding = (maxValue - minValue) * 0.1;
    final minY = minValue - padding;
    final maxY = maxValue + padding;

    // Use a fixed X-axis domain [0..windowSeconds] so the waveform scrolls smoothly
    const double minXVal = 0.0;
    final double maxXVal = windowSeconds.toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: (maxY - minY) / 6,
          verticalInterval: (windowSeconds / 8).clamp(0.5, 5),
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
              interval: (windowSeconds / 6).clamp(0.5, 5),
              getTitlesWidget: (value, meta) {
                // value is within minXVal..maxXVal, show seconds relative to right edge
                final secondsAgo = (maxXVal - value).clamp(0, windowSeconds);
                final display = secondsAgo.round();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '-${display}s',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
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
            barWidth: 1,
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
                final idx = flSpot.x.toInt();
                if (idx < window.length && idx >= 0) {
                  final reading = window[idx];
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
        minX: minXVal,
        maxX: maxXVal,
        minY: minY,
        maxY: maxY,
      ),
    );
  }
}
