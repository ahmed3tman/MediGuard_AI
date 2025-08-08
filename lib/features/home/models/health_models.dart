import 'package:flutter/material.dart';

class LocalizedText {
  final String en;
  final String ar;

  const LocalizedText({required this.en, required this.ar});

  String getByLocale(String locale) {
    return locale.startsWith('ar') ? ar : en;
  }
}

class DevicePromotion {
  final String id;
  final LocalizedText name;
  final LocalizedText shortDescription;
  final LocalizedText fullDescription;
  final String imageAsset;
  final LocalizedText features;
  final LocalizedText price;
  final LocalizedText specifications;
  final LocalizedText warranty;
  final bool isAvailable;

  const DevicePromotion({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.imageAsset,
    required this.features,
    required this.price,
    required this.specifications,
    required this.warranty,
    required this.isAvailable,
  });
}

class HealthTip {
  final String id;
  final LocalizedText title;
  final LocalizedText shortDescription;
  final LocalizedText fullContent;
  final String imageAsset;
  final LocalizedText category;
  final Color categoryColor;
  final DateTime publishedDate;
  final LocalizedText author;
  final int readingTimeMinutes;
  final LocalizedText tags;

  const HealthTip({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullContent,
    required this.imageAsset,
    required this.category,
    required this.categoryColor,
    required this.publishedDate,
    required this.author,
    required this.readingTimeMinutes,
    required this.tags,
  });
}
