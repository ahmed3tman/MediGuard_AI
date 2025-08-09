import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../models/health_models.dart';

class HealthTipCard extends StatelessWidget {
  final HealthTip healthTip;
  final VoidCallback? onTap;

  const HealthTipCard({super.key, required this.healthTip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isTablet = size.width > 600;
    final cardWidth = isTablet ? 300.0 : 260.0;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale.startsWith('ar');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 100,
        margin: EdgeInsets.only(
          right: isTablet ? 10 : 8,
          left: isTablet ? 10 : 8,
          bottom: 6,
          top: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 118, 118, 118).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 1),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: isTablet ? 110 : 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: healthTip.categoryColor.withOpacity(0.1),
                      image: healthTip.imageAsset.startsWith('http')
                          ? DecorationImage(
                              image: NetworkImage(healthTip.imageAsset),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Handle image loading error
                              },
                            )
                          : DecorationImage(
                              image: AssetImage(healthTip.imageAsset),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: healthTip.imageAsset.startsWith('http')
                        ? Container() // NetworkImage will handle display
                        : null, // AssetImage will handle display
                  ),

                  // Category Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: healthTip.categoryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: healthTip.categoryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        healthTip.category.getByLocale(locale),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: isArabic ? 'NeoSansArabic' : null,
                        ),
                      ),
                    ),
                  ),

                  // Reading Time Badge
                  // Positioned(
                  //   top: 8,
                  //   left: 8,
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 8,
                  //       vertical: 3,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.black.withOpacity(0.7),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(
                  //           Icons.access_time,
                  //           color: Colors.white,
                  //           size: isTablet ? 14 : 12,
                  //         ),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           '${healthTip.readingTimeMinutes} د',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: isTablet ? 12 : 10,
                  //             fontWeight: FontWeight.w600,
                  //             fontFamily: 'NeoSansArabic',
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Gradient Overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      healthTip.title.getByLocale(locale),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: isArabic ? 'NeoSansArabic' : null,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isTablet ? 4 : 3),

                    // Description
                    Text(
                      healthTip.shortDescription.getByLocale(locale),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 13 : 12,
                        height: 1.3,
                        fontFamily: isArabic ? 'NeoSansArabic' : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isTablet ? 6 : 5),

                    // Tags
                    Builder(
                      builder: (context) {
                        final tagsList = healthTip.tags
                            .getByLocale(locale)
                            .split('|');
                        if (tagsList.isNotEmpty &&
                            tagsList.first.trim().isNotEmpty) {
                          return Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tagsList.take(2).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: healthTip.categoryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: healthTip.categoryColor.withOpacity(
                                      0.3,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  tag.trim(),
                                  style: TextStyle(
                                    color: healthTip.categoryColor,
                                    fontSize: isTablet ? 10 : 9,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: isArabic
                                        ? 'NeoSansArabic'
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: isTablet ? 5 : 3),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Author
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: isTablet ? 28 : 24,
                                height: isTablet ? 28 : 24,
                                decoration: BoxDecoration(
                                  color: healthTip.categoryColor.withOpacity(
                                    0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: healthTip.categoryColor,
                                  size: isTablet ? 16 : 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  healthTip.author.getByLocale(locale),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: isTablet ? 11 : 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: isArabic
                                        ? 'NeoSansArabic'
                                        : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Read More Arrow
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: healthTip.categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: healthTip.categoryColor,
                            size: isTablet ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
