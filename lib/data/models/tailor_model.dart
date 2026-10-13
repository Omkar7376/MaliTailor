import 'package:cloud_firestore/cloud_firestore.dart';

class TailorModel {
  final String uid;
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final double workerShirtWage;
  final double workerPantWage;
  final DateTime createdAt;
  final DateTime updatedAt;

  TailorModel({
    required this.uid,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.workerShirtWage = 130.0,
    this.workerPantWage = 150.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TailorModel.fromMap(Map<String, dynamic> map, String docId) {
    return TailorModel(
      uid: docId,
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      workerShirtWage: (map['workerShirtWage'] is num)
          ? (map['workerShirtWage'] as num).toDouble()
          : (double.tryParse(map['workerShirtWage']?.toString() ?? '130') ?? 130.0),
      workerPantWage: (map['workerPantWage'] is num)
          ? (map['workerPantWage'] as num).toDouble()
          : (double.tryParse(map['workerPantWage']?.toString() ?? '150') ?? 150.0),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'workerShirtWage': workerShirtWage,
      'workerPantWage': workerPantWage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TailorModel copyWith({
    String? shopName,
    String? ownerName,
    String? email,
    String? phone,
    double? workerShirtWage,
    double? workerPantWage,
  }) {
    return TailorModel(
      uid: uid,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      workerShirtWage: workerShirtWage ?? this.workerShirtWage,
      workerPantWage: workerPantWage ?? this.workerPantWage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
