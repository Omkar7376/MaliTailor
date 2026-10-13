import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String bookNo;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String orderType; // Shirt, Pant, Suit, Both, Custom
  final int shirtQty;
  final double shirtRate;
  final double shirtTotal;
  final int pantQty;
  final double pantRate;
  final double pantTotal;
  final double totalAmount;
  final double discount;
  final double advanceAmount;
  final double finalPayable;
  final String status; // Pending, In Progress, Ready, Delivered, Cancelled
  final String note;
  final String? assignedWorkerId;
  final String? assignedWorkerName;
  final double workerWage; // Total stitching / cutting wage
  // Separate Worker Assignments & Wages for Shirt & Pant
  final String? shirtWorkerId;
  final String? shirtWorkerName;
  final double shirtWorkerWage; // e.g. shirtQty * 130
  final String? pantWorkerId;
  final String? pantWorkerName;
  final double pantWorkerWage; // e.g. pantQty * 150
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.bookNo,
    required this.orderDate,
    required this.deliveryDate,
    this.orderType = 'Both',
    this.shirtQty = 0,
    this.shirtRate = 0.0,
    this.shirtTotal = 0.0,
    this.pantQty = 0,
    this.pantRate = 0.0,
    this.pantTotal = 0.0,
    this.totalAmount = 0.0,
    this.discount = 0.0,
    this.advanceAmount = 0.0,
    this.finalPayable = 0.0,
    this.status = 'Pending',
    this.note = '',
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.workerWage = 0.0,
    this.shirtWorkerId,
    this.shirtWorkerName,
    this.shirtWorkerWage = 0.0,
    this.pantWorkerId,
    this.pantWorkerName,
    this.pantWorkerWage = 0.0,
    this.isUrgent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted worker name showing shirt & pant workers or single assigned worker
  String get workerDisplayName {
    if (shirtWorkerName != null && pantWorkerName != null) {
      if (shirtWorkerName == pantWorkerName) {
        return shirtWorkerName!;
      }
      return '$shirtWorkerName (Shirt) & $pantWorkerName (Pant)';
    } else if (shirtWorkerName != null) {
      return '$shirtWorkerName (Shirt)';
    } else if (pantWorkerName != null) {
      return '$pantWorkerName (Pant)';
    } else if (assignedWorkerName != null && assignedWorkerName!.isNotEmpty) {
      return assignedWorkerName!;
    }
    return 'Unassigned';
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  static DateTime _toDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      orderId: docId,
      customerId: (map['customerId'] ?? '').toString(),
      customerName: (map['customerName'] ?? '').toString(),
      customerMobile: (map['customerMobile'] ?? '').toString(),
      bookNo: (map['bookNo'] ?? '').toString(),
      orderDate: _toDate(map['orderDate']),
      deliveryDate: map['deliveryDate'] != null
          ? _toDate(map['deliveryDate'])
          : DateTime.now().add(const Duration(days: 7)),
      orderType: (map['orderType'] ?? 'Both').toString(),
      shirtQty: _toInt(map['shirtQty']),
      shirtRate: _toDouble(map['shirtRate']),
      shirtTotal: _toDouble(map['shirtTotal']),
      pantQty: _toInt(map['pantQty']),
      pantRate: _toDouble(map['pantRate']),
      pantTotal: _toDouble(map['pantTotal']),
      totalAmount: _toDouble(map['totalAmount']),
      discount: _toDouble(map['discount']),
      advanceAmount: _toDouble(map['advanceAmount']),
      finalPayable: _toDouble(map['finalPayable']),
      status: (map['status'] ?? 'Pending').toString(),
      note: (map['note'] ?? '').toString(),
      assignedWorkerId: map['assignedWorkerId']?.toString(),
      assignedWorkerName: map['assignedWorkerName']?.toString(),
      workerWage: _toDouble(map['workerWage']),
      shirtWorkerId: map['shirtWorkerId']?.toString(),
      shirtWorkerName: map['shirtWorkerName']?.toString(),
      shirtWorkerWage: _toDouble(map['shirtWorkerWage']),
      pantWorkerId: map['pantWorkerId']?.toString(),
      pantWorkerName: map['pantWorkerName']?.toString(),
      pantWorkerWage: _toDouble(map['pantWorkerWage']),
      isUrgent: map['isUrgent'] == true,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'bookNo': bookNo,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'orderType': orderType,
      'shirtQty': shirtQty,
      'shirtRate': shirtRate,
      'shirtTotal': shirtTotal,
      'pantQty': pantQty,
      'pantRate': pantRate,
      'pantTotal': pantTotal,
      'totalAmount': totalAmount,
      'discount': discount,
      'advanceAmount': advanceAmount,
      'finalPayable': finalPayable,
      'status': status,
      'note': note,
      'assignedWorkerId': assignedWorkerId,
      'assignedWorkerName': assignedWorkerName,
      'workerWage': workerWage,
      'shirtWorkerId': shirtWorkerId,
      'shirtWorkerName': shirtWorkerName,
      'shirtWorkerWage': shirtWorkerWage,
      'pantWorkerId': pantWorkerId,
      'pantWorkerName': pantWorkerName,
      'pantWorkerWage': pantWorkerWage,
      'isUrgent': isUrgent,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? customerName,
    String? customerMobile,
    String? bookNo,
    String? orderType,
    int? shirtQty,
    double? shirtRate,
    double? shirtTotal,
    int? pantQty,
    double? pantRate,
    double? pantTotal,
    double? totalAmount,
    double? discount,
    String? status,
    String? note,
    String? assignedWorkerId,
    String? assignedWorkerName,
    double? workerWage,
    String? shirtWorkerId,
    String? shirtWorkerName,
    double? shirtWorkerWage,
    String? pantWorkerId,
    String? pantWorkerName,
    double? pantWorkerWage,
    bool? isUrgent,
    DateTime? deliveryDate,
    double? advanceAmount,
    double? finalPayable,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      bookNo: bookNo ?? this.bookNo,
      orderDate: orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderType: orderType ?? this.orderType,
      shirtQty: shirtQty ?? this.shirtQty,
      shirtRate: shirtRate ?? this.shirtRate,
      shirtTotal: shirtTotal ?? this.shirtTotal,
      pantQty: pantQty ?? this.pantQty,
      pantRate: pantRate ?? this.pantRate,
      pantTotal: pantTotal ?? this.pantTotal,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      finalPayable: finalPayable ?? this.finalPayable,
      status: status ?? this.status,
      note: note ?? this.note,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      workerWage: workerWage ?? this.workerWage,
      shirtWorkerId: shirtWorkerId ?? this.shirtWorkerId,
      shirtWorkerName: shirtWorkerName ?? this.shirtWorkerName,
      shirtWorkerWage: shirtWorkerWage ?? this.shirtWorkerWage,
      pantWorkerId: pantWorkerId ?? this.pantWorkerId,
      pantWorkerName: pantWorkerName ?? this.pantWorkerName,
      pantWorkerWage: pantWorkerWage ?? this.pantWorkerWage,
      isUrgent: isUrgent ?? this.isUrgent,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
