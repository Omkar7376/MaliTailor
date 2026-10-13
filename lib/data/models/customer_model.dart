import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String bookNo; // Physical ledger record book number
  final String name;
  final String mobile;
  final String gender; // Male, Female, Other
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.bookNo,
    required this.name,
    required this.mobile,
    this.gender = 'Male',
    this.address = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerModel(
      id: docId,
      bookNo: (map['bookNo'] ?? '').toString(),
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      gender: map['gender'] ?? 'Male',
      address: map['address'] ?? '',
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
      'id': id,
      'bookNo': bookNo,
      'name': name,
      'mobile': mobile,
      'gender': gender,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CustomerModel copyWith({
    String? bookNo,
    String? name,
    String? mobile,
    String? gender,
    String? address,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id,
      bookNo: bookNo ?? this.bookNo,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
