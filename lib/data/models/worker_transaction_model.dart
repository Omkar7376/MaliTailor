import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkerTransactionType {
  advance, // Advance cash / extra money taken by worker from shop (to be minus from salary)
  payout,  // Settlement / Salary paid out to worker
  wage,    // Order piece-rate wage earned
}

class WorkerTransactionModel {
  final String transactionId;
  final String workerId;
  final String workerName;
  final WorkerTransactionType type; // advance, payout, wage
  final double amount;
  final String? orderId; // Linked order if wage or specific advance
  final String note;
  final DateTime date;
  final DateTime createdAt;

  WorkerTransactionModel({
    required this.transactionId,
    required this.workerId,
    required this.workerName,
    required this.type,
    required this.amount,
    this.orderId,
    this.note = '',
    required this.date,
    required this.createdAt,
  });

  factory WorkerTransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    WorkerTransactionType parseType(String? val) {
      if (val == 'payout') return WorkerTransactionType.payout;
      if (val == 'wage') return WorkerTransactionType.wage;
      return WorkerTransactionType.advance;
    }

    return WorkerTransactionModel(
      transactionId: docId,
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? '',
      type: parseType(map['type']),
      amount: (map['amount'] ?? 0.0) is num
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount'].toString()) ?? 0.0,
      orderId: map['orderId'],
      note: map['note'] ?? '',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'workerId': workerId,
      'workerName': workerName,
      'type': type.name,
      'amount': amount,
      'orderId': orderId,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  WorkerTransactionModel copyWith({
    String? workerName,
    WorkerTransactionType? type,
    double? amount,
    String? orderId,
    String? note,
    DateTime? date,
  }) {
    return WorkerTransactionModel(
      transactionId: transactionId,
      workerId: workerId,
      workerName: workerName ?? this.workerName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      orderId: orderId ?? this.orderId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
