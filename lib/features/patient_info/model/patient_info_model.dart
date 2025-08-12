import 'package:equatable/equatable.dart';

enum Gender { male, female }

class PatientInfo extends Equatable {
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
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      deviceId: json['deviceId'] ?? '',
      patientName: json['patientName'],
      age: json['age'] ?? 0,
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.male,
      ),
      bloodType: json['bloodType'],
      phoneNumber: json['phoneNumber'] ?? '',
      chronicDiseases: List<String>.from(json['chronicDiseases'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  PatientInfo copyWith({
    String? deviceId,
    String? patientName,
    int? age,
    Gender? gender,
    String? bloodType,
    String? phoneNumber,
    List<String>? chronicDiseases,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientInfo(
      deviceId: deviceId ?? this.deviceId,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    bloodType,
    phoneNumber,
    chronicDiseases,
    notes,
    createdAt,
    updatedAt,
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
