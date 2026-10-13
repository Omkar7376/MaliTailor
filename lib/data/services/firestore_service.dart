import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';
import '../models/shirt_measurement_model.dart';
import '../models/pant_measurement_model.dart';
import '../models/order_model.dart';
import '../models/worker_model.dart';
import '../models/worker_transaction_model.dart';
import '../models/tailor_model.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory fallback dataset for instant responsiveness
  final List<CustomerModel> _mockCustomers = [];
  final Map<String, ShirtMeasurementModel> _mockShirtMeasurements = {};
  final Map<String, PantMeasurementModel> _mockPantMeasurements = {};
  final List<OrderModel> _mockOrders = [];
  final List<WorkerModel> _mockWorkers = [];
  final List<WorkerTransactionModel> _mockWorkerTransactions = [];
  TailorModel _mockTailor = TailorModel(
    uid: 'admin_studio_01',
    shopName: 'Mali Tailor',
    ownerName: 'Mahadev Mali',
    email: 'admin@stitchup.com',
    phone: '+91 99609 45720',
    workerShirtWage: 130.0,
    workerPantWage: 150.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final StreamController<List<CustomerModel>> _customersStreamController =
      StreamController<List<CustomerModel>>.broadcast();
  final StreamController<List<OrderModel>> _ordersStreamController =
      StreamController<List<OrderModel>>.broadcast();
  final StreamController<List<WorkerModel>> _workersStreamController =
      StreamController<List<WorkerModel>>.broadcast();
  final StreamController<List<WorkerTransactionModel>> _workerTransactionsStreamController =
      StreamController<List<WorkerTransactionModel>>.broadcast();
  final StreamController<TailorModel> _tailorStreamController =
      StreamController<TailorModel>.broadcast();

  FirestoreService() {
    _emitStreams();
    // Ensure admin profile exists in Firestore
    autoInitializeCollections('admin_studio_01');
  }

  /// Automatically ensures Tailor Profile Document exists in Cloud Firestore
  Future<void> autoInitializeCollections(String tailorId) async {
    if (!FirebaseService.isFirebaseInitialized || tailorId.isEmpty) return;

    try {
      final tailorDocRef = _firestore.collection('tailors').doc(tailorId);
      final tailorDoc = await tailorDocRef.get();

      // Ensure Tailor Profile Document exists
      if (!tailorDoc.exists) {
        await tailorDocRef.set({
          'uid': tailorId,
          'shopName': _mockTailor.shopName,
          'ownerName': _mockTailor.ownerName,
          'email': _mockTailor.email,
          'phone': _mockTailor.phone,
          'workerShirtWage': _mockTailor.workerShirtWage,
          'workerPantWage': _mockTailor.workerPantWage,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Verified admin tailor profile: tailors/$tailorId');
      }
    } catch (e) {
      debugPrint('Firestore autoInitialize error (fallback active): $e');
    }
  }

  void _emitStreams() {
    _customersStreamController.add(List.unmodifiable(_mockCustomers));
    _ordersStreamController.add(List.unmodifiable(_mockOrders));
    _workersStreamController.add(List.unmodifiable(_mockWorkers));
    _workerTransactionsStreamController.add(List.unmodifiable(_mockWorkerTransactions));
    _tailorStreamController.add(_mockTailor);
  }

  // --- Tailor Profile & Settings ---
  Stream<TailorModel> getTailorProfile(String tailorId) {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      return _firestore
          .collection('tailors')
          .doc(tailorId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return TailorModel.fromMap(snapshot.data()!, snapshot.id);
        }
        return _mockTailor;
      });
    }
    return _tailorStreamController.stream;
  }

  Future<void> updateTailorWageRates(String tailorId, double shirtWage, double pantWage) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore.collection('tailors').doc(tailorId).update({
          'workerShirtWage': shirtWage,
          'workerPantWage': pantWage,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore updateTailorWageRates error: $e');
      }
    }
    _mockTailor = _mockTailor.copyWith(
      workerShirtWage: shirtWage,
      workerPantWage: pantWage,
    );
    _emitStreams();
  }

  // --- Customers ---
  Stream<List<CustomerModel>> getCustomers(String tailorId) {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      return _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    }
    return _customersStreamController.stream;
  }

  Future<void> addCustomer(String tailorId, CustomerModel customer) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('customers')
            .doc(customer.id)
            .set(customer.toMap());
      } catch (e) {
        debugPrint('Firestore addCustomer error: $e');
      }
    }
    _mockCustomers.insert(0, customer);
    _emitStreams();
  }

  Future<void> updateCustomer(String tailorId, CustomerModel customer) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customer.id)
          .update(customer.toMap());
    }
    final index = _mockCustomers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _mockCustomers[index] = customer;
      _emitStreams();
    }
  }

  Future<void> deleteCustomer(String tailorId, String customerId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customerId)
          .delete();
    }
    _mockCustomers.removeWhere((c) => c.id == customerId);
    _emitStreams();
  }

  Future<CustomerModel?> getCustomerById(String tailorId, String customerId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      final doc = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customerId)
          .get();
      if (doc.exists && doc.data() != null) {
        return CustomerModel.fromMap(doc.data()!, doc.id);
      }
    }
    try {
      return _mockCustomers.firstWhere((c) => c.id == customerId);
    } catch (_) {
      return null;
    }
  }

  // --- Measurements ---
  Future<ShirtMeasurementModel> getShirtMeasurement(String tailorId, String customerId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      final doc = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customerId)
          .collection('measurements')
          .doc('shirt')
          .get();
      if (doc.exists && doc.data() != null) {
        return ShirtMeasurementModel.fromMap(doc.data());
      }
    }
    return _mockShirtMeasurements[customerId] ?? ShirtMeasurementModel.empty();
  }

  Future<void> saveShirtMeasurement(String tailorId, String customerId, ShirtMeasurementModel measurement) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customerId)
          .collection('measurements')
          .doc('shirt')
          .set(measurement.toMap(), SetOptions(merge: true));
    }
    _mockShirtMeasurements[customerId] = measurement;
  }

  Future<PantMeasurementModel> getPantMeasurement(String tailorId, String customerId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      final doc = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customerId)
          .collection('measurements')
          .doc('pant')
          .get();
      if (doc.exists && doc.data() != null) {
        return PantMeasurementModel.fromMap(doc.data());
      }
    }
    return _mockPantMeasurements[customerId] ?? PantMeasurementModel.empty();
  }

  Future<void> savePantMeasurement(String tailorId, String customerId, PantMeasurementModel measurement) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('customers')
          .doc(customerId)
          .collection('measurements')
          .doc('pant')
          .set(measurement.toMap(), SetOptions(merge: true));
    }
    _mockPantMeasurements[customerId] = measurement;
  }

  // --- Orders ---
  Stream<List<OrderModel>> getOrders(String tailorId) {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      return _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('orders')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final remoteOrders = <OrderModel>[];
          for (final doc in snapshot.docs) {
            try {
              remoteOrders.add(OrderModel.fromMap(doc.data(), doc.id));
            } catch (e) {
              debugPrint('Error parsing order ${doc.id}: $e');
            }
          }
          // Sort real-time orders descending by createdAt/orderDate
          remoteOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return remoteOrders;
        }
        return <OrderModel>[];
      });
    }
    // Emit current mock state immediately for instant display
    Future.microtask(() => _ordersStreamController.add(List.unmodifiable(_mockOrders)));
    return _ordersStreamController.stream;
  }

  Future<void> addOrder(String tailorId, OrderModel order) async {
    _mockOrders.insert(0, order);
    _emitStreams();

    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('orders')
            .doc(order.orderId)
            .set(order.toMap());
      } catch (e) {
        debugPrint('Firestore addOrder warning (offline fallback active): $e');
      }
    }
  }

  Future<void> updateOrderStatus(String tailorId, String orderId, String status) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    final index = _mockOrders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(status: status);
      _emitStreams();
    }
  }

  Future<void> updateOrder(String tailorId, OrderModel order) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('orders')
          .doc(order.orderId)
          .update(order.toMap());
    }
    final index = _mockOrders.indexWhere((o) => o.orderId == order.orderId);
    if (index != -1) {
      _mockOrders[index] = order;
      _emitStreams();
    }
  }

  Future<void> deleteOrder(String tailorId, String orderId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('orders')
            .doc(orderId)
            .delete();
      } catch (e) {
        debugPrint('Firestore deleteOrder error: $e');
      }
    }
    _mockOrders.removeWhere((o) => o.orderId == orderId);
    _emitStreams();
  }

  Future<void> assignWorkerToOrder(
    String tailorId,
    String orderId,
    String workerId,
    String workerName, {
    double? workerWage,
  }) async {
    final updateData = <String, dynamic>{
      'assignedWorkerId': workerId,
      'assignedWorkerName': workerName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (workerWage != null) {
      updateData['workerWage'] = workerWage;
    }

    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('orders')
          .doc(orderId)
          .update(updateData);
    }
    final index = _mockOrders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(
        assignedWorkerId: workerId,
        assignedWorkerName: workerName,
        workerWage: workerWage ?? _mockOrders[index].workerWage,
      );
      _emitStreams();
    }
  }

  // --- Workers ---
  Stream<List<WorkerModel>> getWorkers(String tailorId) {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      return _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('workers')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => WorkerModel.fromMap(doc.data(), doc.id))
              .toList();
        }
        return _mockWorkers;
      });
    }
    return _workersStreamController.stream;
  }

  Future<void> addWorker(String tailorId, WorkerModel worker) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('workers')
          .doc(worker.workerId)
          .set(worker.toMap());
    }
    _mockWorkers.add(worker);
    _emitStreams();
  }

  Future<void> updateWorker(String tailorId, WorkerModel worker) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('workers')
            .doc(worker.workerId)
            .update(worker.toMap());

        // Also update any orders assigned to this worker in Firestore
        final ordersSnap = await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('orders')
            .get();

        for (final doc in ordersSnap.docs) {
          final data = doc.data();
          final Map<String, dynamic> updates = {};
          if (data['assignedWorkerId'] == worker.workerId) {
            updates['assignedWorkerName'] = worker.name;
          }
          if (data['shirtWorkerId'] == worker.workerId) {
            updates['shirtWorkerName'] = worker.name;
          }
          if (data['pantWorkerId'] == worker.workerId) {
            updates['pantWorkerName'] = worker.name;
          }
          if (updates.isNotEmpty) {
            await doc.reference.update(updates);
          }
        }
      } catch (e) {
        debugPrint('Firestore updateWorker cascade error: $e');
      }
    }
    final index = _mockWorkers.indexWhere((w) => w.workerId == worker.workerId);
    if (index != -1) {
      _mockWorkers[index] = worker;
    }

    // Cascade update to mock orders
    for (int i = 0; i < _mockOrders.length; i++) {
      final o = _mockOrders[i];
      bool changed = false;
      String? aName = o.assignedWorkerName;
      String? sName = o.shirtWorkerName;
      String? pName = o.pantWorkerName;

      if (o.assignedWorkerId == worker.workerId) {
        aName = worker.name;
        changed = true;
      }
      if (o.shirtWorkerId == worker.workerId) {
        sName = worker.name;
        changed = true;
      }
      if (o.pantWorkerId == worker.workerId) {
        pName = worker.name;
        changed = true;
      }

      if (changed) {
        _mockOrders[i] = o.copyWith(
          assignedWorkerName: aName,
          shirtWorkerName: sName,
          pantWorkerName: pName,
        );
      }
    }

    // Cascade update to mock worker transactions
    for (int i = 0; i < _mockWorkerTransactions.length; i++) {
      final t = _mockWorkerTransactions[i];
      if (t.workerId == worker.workerId) {
        _mockWorkerTransactions[i] = WorkerTransactionModel(
          transactionId: t.transactionId,
          workerId: t.workerId,
          workerName: worker.name,
          type: t.type,
          amount: t.amount,
          orderId: t.orderId,
          note: t.note,
          date: t.date,
          createdAt: t.createdAt,
        );
      }
    }

    _emitStreams();
  }

  Future<void> deleteWorker(String tailorId, String workerId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('workers')
            .doc(workerId)
            .delete();
      } catch (e) {
        debugPrint('Firestore deleteWorker error: $e');
      }
    }
    _mockWorkers.removeWhere((w) => w.workerId == workerId);
    _emitStreams();
  }

  // --- Worker Transactions (Advances, Payments, Deductions) ---
  Stream<List<WorkerTransactionModel>> getWorkerTransactions(String tailorId) {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      return _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('worker_transactions')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => WorkerTransactionModel.fromMap(doc.data(), doc.id))
              .toList();
        }
        return _mockWorkerTransactions;
      });
    }
    return _workerTransactionsStreamController.stream;
  }

  Future<void> addWorkerTransaction(String tailorId, WorkerTransactionModel tx) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('worker_transactions')
          .doc(tx.transactionId)
          .set(tx.toMap());
    }
    _mockWorkerTransactions.insert(0, tx);
    _emitStreams();
  }

  Future<void> updateWorkerTransaction(String tailorId, WorkerTransactionModel tx) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('worker_transactions')
            .doc(tx.transactionId)
            .update(tx.toMap());
      } catch (e) {
        debugPrint('Firestore updateWorkerTransaction error: $e');
      }
    }
    final index = _mockWorkerTransactions.indexWhere((t) => t.transactionId == tx.transactionId);
    if (index != -1) {
      _mockWorkerTransactions[index] = tx;
      _emitStreams();
    }
  }

  Future<void> deleteWorkerTransaction(String tailorId, String transactionId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        await _firestore
            .collection('tailors')
            .doc(tailorId)
            .collection('worker_transactions')
            .doc(transactionId)
            .delete();
      } catch (e) {
        debugPrint('Firestore deleteWorkerTransaction error: $e');
      }
    }
    _mockWorkerTransactions.removeWhere((t) => t.transactionId == transactionId);
    _emitStreams();
  }

  /// Wipes all records (customers, measurements, orders, workers, worker_transactions)
  /// from Firestore and memory while preserving the admin tailor profile document.
  Future<void> clearAllRecordsExceptAdmin(String tailorId) async {
    if (FirebaseService.isFirebaseInitialized && tailorId.isNotEmpty) {
      try {
        final tailorDocRef = _firestore.collection('tailors').doc(tailorId);

        // Helper to delete all documents in a collection
        Future<void> deleteCollection(CollectionReference col) async {
          final snapshot = await col.get();
          for (final doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }

        // 1. Delete all measurements under each customer first, then customers
        final custSnapshot = await tailorDocRef.collection('customers').get();
        for (final doc in custSnapshot.docs) {
          final measSnapshot = await doc.reference.collection('measurements').get();
          for (final mDoc in measSnapshot.docs) {
            await mDoc.reference.delete();
          }
          await doc.reference.delete();
        }

        // 2. Delete all orders
        await deleteCollection(tailorDocRef.collection('orders'));

        // 3. Delete all workers
        await deleteCollection(tailorDocRef.collection('workers'));

        // 4. Delete all worker transactions
        await deleteCollection(tailorDocRef.collection('worker_transactions'));

        debugPrint('✅ Cleared all database records from Firestore for tailorId=$tailorId');
      } catch (e) {
        debugPrint('Error clearing Firestore collections: $e');
      }
    }

    // Clear all in-memory mock records
    _mockCustomers.clear();
    _mockShirtMeasurements.clear();
    _mockPantMeasurements.clear();
    _mockOrders.clear();
    _mockWorkers.clear();
    _mockWorkerTransactions.clear();
    _emitStreams();
  }
}

