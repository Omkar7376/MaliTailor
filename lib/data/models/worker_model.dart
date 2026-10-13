class WorkerModel {
  final String workerId;
  final String name;
  final String phone;
  final String role; // Master Cutter, Stitcher, Finisher
  final List<String> assignedOrderIds;

  WorkerModel({
    required this.workerId,
    required this.name,
    required this.phone,
    this.role = 'Stitcher',
    this.assignedOrderIds = const [],
  });

  factory WorkerModel.fromMap(Map<String, dynamic> map, String docId) {
    return WorkerModel(
      workerId: docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'Stitcher',
      assignedOrderIds: (map['assignedOrderIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'name': name,
      'phone': phone,
      'role': role,
      'assignedOrderIds': assignedOrderIds,
    };
  }

  WorkerModel copyWith({
    String? name,
    String? phone,
    String? role,
    List<String>? assignedOrderIds,
  }) {
    return WorkerModel(
      workerId: workerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      assignedOrderIds: assignedOrderIds ?? this.assignedOrderIds,
    );
  }
}
