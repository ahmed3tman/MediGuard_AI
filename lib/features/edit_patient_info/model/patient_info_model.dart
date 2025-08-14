import 'package:equatable/equatable.dart';
import '../../devices/model/data_model.dart';

enum Gender { male, female }

/// Unified Patient model that now contains the associated device as a nested object
/// Firebase path structure after refactor:
/// users/{userId}/patients/{patientId} => {
///   id: patientId,
///   name / age / gender / ... patient fields,
///   device: { deviceId, name(model), readings { ... }, lastUpdated }
/// }
class PatientInfo extends Equatable {
  /// Acts as both patient unique id and (legacy) deviceId reference
  final String deviceId;
  final String? patientName;
  final int age;
  final Gender gender;
  final String? bloodType;
  final String? phoneNumber;
  final List<String> chronicDiseases;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True if gender was explicitly provided in source data (not a default)
  final bool genderExplicit;

  /// Nested device (can be null for backward compatibility / before device creation)
  final Device? device;

  const PatientInfo({
    required this.deviceId,
    this.patientName,
    required this.age,
    required this.gender,
    this.bloodType,
    this.phoneNumber,
    required this.chronicDiseases,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.device,
    this.genderExplicit = false,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    // دعم البنية الجديدة: العقدة قد تحتوي على 'info' كحاوية للحقول
    final base = json['info'] is Map
        ? Map<String, dynamic>.from(json['info'])
        : json; // توافق عكسي مع البنية القديمة

    // Normalize gender from multiple possible representations (Arabic/English)
    Gender _parseGender(dynamic value) {
      final v = (value?.toString() ?? '').trim().toLowerCase();
      if (v.isEmpty) return Gender.male; // keep existing default for compat
      final malePatterns = ['male', 'm', 'man', 'ذكر', 'ولد', 'رجل'];
      final femalePatterns = [
        'female',
        'f',
        'woman',
        'girl',
        'أنثى',
        'انثى',
        'بنت',
        'امرأة',
        'سيدة',
      ];
      if (femalePatterns.any((p) => v == p || v.contains(p)))
        return Gender.female;
      if (malePatterns.any((p) => v == p || v.contains(p))) return Gender.male;
      return Gender.male; // fallback for unknown
    }

    final bool hasGender =
        base.containsKey('gender') &&
        base['gender'] != null &&
        base['gender'].toString().trim().isNotEmpty;

    return PatientInfo(
      deviceId:
          base['deviceId'] ??
          base['id'] ??
          json['deviceId'] ??
          json['id'] ??
          '',
      patientName: base['patientName'] ?? base['name'],
      age: base['age'] ?? 0,
      gender: _parseGender(base['gender']),
      genderExplicit: hasGender,
      bloodType: base['bloodType'],
      phoneNumber: base['phoneNumber'] ?? '',
      chronicDiseases: List<String>.from(base['chronicDiseases'] ?? []),
      notes: base['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        base['createdAt'] ?? json['createdAt'] ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        base['updatedAt'] ?? json['updatedAt'] ?? 0,
      ),
      device: json['device'] != null && json['device'] is Map
          ? Device.fromJson(Map<String, dynamic>.from(json['device']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Keep both id & deviceId for backward compatibility
      'id': deviceId,
      'deviceId': deviceId,
      'patientName': patientName,
      'age': age,
      'gender': gender.name,
      'bloodType': bloodType,
      'phoneNumber': phoneNumber,
      'chronicDiseases': chronicDiseases,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      if (device != null) 'device': device!.toJson(),
      // Not stored as authoritative, but useful in local flows
      'genderExplicit': genderExplicit,
    };
  }

  // تحويل خاص لكتابة بيانات المريض فقط داخل مسار info
  Map<String, dynamic> toProfileJson() {
    return {
      'id': deviceId,
      'deviceId': deviceId,
      'patientName': patientName,
      'age': age,
      'gender': gender.name,
      'bloodType': bloodType,
      'phoneNumber': phoneNumber,
      'chronicDiseases': chronicDiseases,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'genderExplicit': genderExplicit,
    };
  }

  PatientInfo copyWith({
    String? deviceId,
    String? patientName,
    int? age,
    Gender? gender,
    bool? genderExplicit,
    String? bloodType,
    String? phoneNumber,
    List<String>? chronicDiseases,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Device? device,
  }) {
    return PatientInfo(
      deviceId: deviceId ?? this.deviceId,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      genderExplicit: genderExplicit ?? this.genderExplicit,
      bloodType: bloodType ?? this.bloodType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      device: device ?? this.device,
    );
  }

  String get genderDisplayName => gender == Gender.male ? 'ذكر' : 'أنثى';

  String get chronicDiseasesDisplay =>
      chronicDiseases.isEmpty ? 'لا يوجد' : chronicDiseases.join(', ');

  @override
  List<Object?> get props => [
    deviceId,
    patientName,
    age,
    gender,
    genderExplicit,
    bloodType,
    phoneNumber,
    chronicDiseases,
    notes,
    createdAt,
    updatedAt,
    device,
  ];
}

// List of common chronic diseases in Arabic
class ChronicDiseases {
  static const List<String> diseases = [
    'لا يوجد',
    'السكري',
    'ارتفاع ضغط الدم',
    'أمراض القلب',
    'الربو',
    'أمراض الكلى المزمنة',
    'أمراض الكبد',
    'التهاب المفاصل الروماتويدي',
    'هشاشة العظام',
    'الصرع',
    'أمراض الغدة الدرقية',
    'السرطان',
    'الاكتئاب',
    'القلق',
    'أمراض الجهاز الهضمي المزمنة',
    'الصداع النصفي',
  ];

  static List<String> getSelectedDiseases(List<String> selected) {
    if (selected.contains('لا يوجد')) {
      return ['لا يوجد'];
    }
    return selected.where((disease) => disease != 'لا يوجد').toList();
  }
}

// Blood types in Arabic
class BloodTypes {
  static const List<String> types = [
    'غير محدد',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
}
