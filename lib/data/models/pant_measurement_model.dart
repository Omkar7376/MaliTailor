import 'package:cloud_firestore/cloud_firestore.dart';

class PantMeasurementModel {
  final String outsideLength;
  final String insideLength;
  final String waist;
  final String seat;
  final String thigh;
  final String knee;
  final String bottom;
  final String rise;
  final String notes;
  final DateTime updatedAt;

  PantMeasurementModel({
    this.outsideLength = '',
    this.insideLength = '',
    this.waist = '',
    this.seat = '',
    this.thigh = '',
    this.knee = '',
    this.bottom = '',
    this.rise = '',
    this.notes = '',
    required this.updatedAt,
  });

  factory PantMeasurementModel.empty() {
    return PantMeasurementModel(
      updatedAt: DateTime.now(),
    );
  }

  factory PantMeasurementModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return PantMeasurementModel.empty();
    return PantMeasurementModel(
      outsideLength: (map['outsideLength'] ?? '').toString(),
      insideLength: (map['insideLength'] ?? '').toString(),
      waist: (map['waist'] ?? '').toString(),
      seat: (map['seat'] ?? '').toString(),
      thigh: (map['thigh'] ?? '').toString(),
      knee: (map['knee'] ?? '').toString(),
      bottom: (map['bottom'] ?? '').toString(),
      rise: (map['rise'] ?? '').toString(),
      notes: map['notes'] ?? '',
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'outsideLength': outsideLength,
      'insideLength': insideLength,
      'waist': waist,
      'seat': seat,
      'thigh': thigh,
      'knee': knee,
      'bottom': bottom,
      'rise': rise,
      'notes': notes,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PantMeasurementModel copyWith({
    String? outsideLength,
    String? insideLength,
    String? waist,
    String? seat,
    String? thigh,
    String? knee,
    String? bottom,
    String? rise,
    String? notes,
  }) {
    return PantMeasurementModel(
      outsideLength: outsideLength ?? this.outsideLength,
      insideLength: insideLength ?? this.insideLength,
      waist: waist ?? this.waist,
      seat: seat ?? this.seat,
      thigh: thigh ?? this.thigh,
      knee: knee ?? this.knee,
      bottom: bottom ?? this.bottom,
      rise: rise ?? this.rise,
      notes: notes ?? this.notes,
      updatedAt: DateTime.now(),
    );
  }
}
