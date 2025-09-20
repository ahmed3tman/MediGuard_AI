import 'package:flutter/material.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../edit_patient_info/model/patient_info_model.dart';
import 'patient_info_item.dart';
import 'chronic_diseases_section.dart';
import 'notes_section.dart';

class PatientInfoCard extends StatelessWidget {
  final PatientInfo patientInfo;
  final VoidCallback? onEdit;

  const PatientInfoCard({super.key, required this.patientInfo, this.onEdit});

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    if (dateTime.millisecondsSinceEpoch == 0) return '';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.05),
            AppColors.primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, title and edit button
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).patientInformation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NeoSansArabic',
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          color: AppColors.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          AppLocalizations.of(context).edit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NeoSansArabic',
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Patient name and device ID in white container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                // Patient name row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${AppLocalizations.of(context).patientName}:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: 'NeoSansArabic',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        patientInfo.patientName ??
                            patientInfo.device?.name ??
                            AppLocalizations.of(context).notSpecified,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NeoSansArabic',
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Device ID row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${AppLocalizations.of(context).deviceId}:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: 'NeoSansArabic',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        patientInfo.deviceId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NeoSansArabic',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Patient information grid
          Row(
            children: [
              Expanded(
                child: PatientInfoItem(
                  icon: Icons.cake,
                  label: AppLocalizations.of(context).age,
                  value: patientInfo.age > 0
                      ? '${patientInfo.age} ${AppLocalizations.of(context).years}'
                      : AppLocalizations.of(context).notSpecified,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PatientInfoItem(
                  icon: patientInfo.gender == Gender.male
                      ? Icons.male
                      : Icons.female,
                  label: AppLocalizations.of(context).gender,
                  value: patientInfo.gender == Gender.male
                      ? AppLocalizations.of(context).male
                      : AppLocalizations.of(context).female,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.water_drop,
                  label: AppLocalizations.of(context).bloodType,
                  value:
                      (patientInfo.bloodType == null ||
                          patientInfo.bloodType!.trim().isEmpty)
                      ? AppLocalizations.of(context).notSpecified
                      : patientInfo.bloodType!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.phone,
                  label: AppLocalizations.of(context).phone,
                  value:
                      (patientInfo.phoneNumber == null ||
                          patientInfo.phoneNumber!.trim().isEmpty)
                      ? AppLocalizations.of(context).notSpecified
                      : patientInfo.phoneNumber!,
                ),
              ),
            ],
          ),

          // Chronic diseases section
          if (patientInfo.chronicDiseases.isNotEmpty &&
              !patientInfo.chronicDiseases.contains('لا يوجد')) ...[
            const SizedBox(height: 12),
            ChronicDiseasesSection(diseases: patientInfo.chronicDiseases),
          ],

          // Notes section
          if (patientInfo.notes != null && patientInfo.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            NotesSection(notes: patientInfo.notes!),
          ],

          // Footer: last updated time (tight at the bottom)
          const SizedBox(height: 10),
          if (patientInfo.updatedAt.millisecondsSinceEpoch != 0)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context).lastUpdatedLabel}${_formatTime(patientInfo.updatedAt, AppLocalizations.of(context))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'NeoSansArabic',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return PatientInfoItem(icon: icon, label: label, value: value);
  }

  Widget _buildChronicDiseasesSection(BuildContext context) {
    return ChronicDiseasesSection(diseases: patientInfo.chronicDiseases);
  }

  Widget _buildNotesSection(BuildContext context) {
    return NotesSection(notes: patientInfo.notes!);
  }
}
