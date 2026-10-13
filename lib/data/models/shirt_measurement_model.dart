import 'package:cloud_firestore/cloud_firestore.dart';

class ShirtMeasurementModel {
  final String length;
  final String chest;
  final String shoulder;
  final String sleeve;
  final String collar;
  final String cuff;
  final String bicep;
  final String back;
  final String front1;
  final String front2;
  final String front3;
  final String notes;
  final DateTime updatedAt;

  ShirtMeasurementModel({
    this.length = '',
    this.chest = '',
    this.shoulder = '',
    this.sleeve = '',
    this.collar = '',
    this.cuff = '',
    this.bicep = '',
    this.back = '',
    this.front1 = '',
    this.front2 = '',
    this.front3 = '',
    this.notes = '',
    required this.updatedAt,
  });

  factory ShirtMeasurementModel.empty() {
    return ShirtMeasurementModel(
      updatedAt: DateTime.now(),
    );
  }

  factory ShirtMeasurementModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ShirtMeasurementModel.empty();
    return ShirtMeasurementModel(
      length: (map['length'] ?? '').toString(),
      chest: (map['chest'] ?? '').toString(),
      shoulder: (map['shoulder'] ?? '').toString(),
      sleeve: (map['sleeve'] ?? '').toString(),
      collar: (map['collar'] ?? '').toString(),
      cuff: (map['cuff'] ?? '').toString(),
      bicep: (map['bicep'] ?? '').toString(),
      back: (map['back'] ?? '').toString(),
      front1: (map['front1'] ?? '').toString(),
      front2: (map['front2'] ?? '').toString(),
      front3: (map['front3'] ?? '').toString(),
      notes: map['notes'] ?? '',
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'length': length,
      'chest': chest,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'collar': collar,
      'cuff': cuff,
      'bicep': bicep,
      'back': back,
      'front1': front1,
      'front2': front2,
      'front3': front3,
      'notes': notes,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ShirtMeasurementModel copyWith({
    String? length,
    String? chest,
    String? shoulder,
    String? sleeve,
    String? collar,
    String? cuff,
    String? bicep,
    String? back,
    String? front1,
    String? front2,
    String? front3,
    String? notes,
  }) {
    return ShirtMeasurementModel(
      length: length ?? this.length,
      chest: chest ?? this.chest,
      shoulder: shoulder ?? this.shoulder,
      sleeve: sleeve ?? this.sleeve,
      collar: collar ?? this.collar,
      cuff: cuff ?? this.cuff,
      bicep: bicep ?? this.bicep,
      back: back ?? this.back,
      front1: front1 ?? this.front1,
      front2: front2 ?? this.front2,
      front3: front3 ?? this.front3,
      notes: notes ?? this.notes,
      updatedAt: DateTime.now(),
    );
  }
}
