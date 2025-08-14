import 'package:flutter/material.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../model/patient_info_model.dart';

class PatientInfoCard extends StatelessWidget {
  final PatientInfo patientInfo;
  final VoidCallback? onEdit;

  const PatientInfoCard({super.key, required this.patientInfo, this.onEdit});

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
                child: _buildInfoItem(
                  context,
                  icon: Icons.cake,
                  label: AppLocalizations.of(context).age,
                  value: patientInfo.age > 0
                      ? '${patientInfo.age} ${AppLocalizations.of(context).years}'
                      : AppLocalizations.of(context).notSpecified,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  context,
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
            _buildChronicDiseasesSection(context),
          ],

          // Notes section
          if (patientInfo.notes != null && patientInfo.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildNotesSection(context),
          ],
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'NeoSansArabic',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChronicDiseasesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                size: 14,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).chronicDiseases,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'NeoSansArabic',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 3,
            children: patientInfo.chronicDiseases.map((disease) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  disease,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryColor,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 14, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).notes,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'NeoSansArabic',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            patientInfo.notes!,
            style: const TextStyle(fontSize: 12, fontFamily: 'NeoSansArabic'),
          ),
        ],
      ),
    );
  }
}
