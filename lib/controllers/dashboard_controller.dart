import 'package:get/get.dart';
import 'customer_controller.dart';
import 'order_controller.dart';
import '../data/models/order_model.dart';

class DashboardController extends GetxController {
  final CustomerController _customerController = Get.find<CustomerController>();
  final OrderController _orderController = Get.find<OrderController>();

  int get totalCustomersCount => _customerController.allCustomers.length;

  int get activeOrdersCount {
    return _orderController.allOrders
        .where((o) => o.status != 'Delivered' && o.status != 'Cancelled')
        .length;
  }

  int get pendingOrdersCount {
    return _orderController.allOrders.where((o) => o.status == 'Pending').length;
  }

  int get inProgressOrdersCount {
    return _orderController.allOrders.where((o) => o.status == 'In Progress').length;
  }

  int get pendingDeliveriesCount {
    // Count orders that are either explicitly 'Pending', marked urgent, or active and due soon
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _orderController.allOrders.where((o) {
      if (o.status == 'Delivered' || o.status == 'Cancelled') return false;
      if (o.status == 'Pending' || o.isUrgent) return true;
      final del = DateTime(o.deliveryDate.year, o.deliveryDate.month, o.deliveryDate.day);
      return del.isBefore(today.add(const Duration(days: 3)));
    }).length;
  }

  int get deliveredTodayCount {
    final now = DateTime.now();
    return _orderController.allOrders.where((o) {
      if (o.status != 'Delivered') return false;
      return o.updatedAt.year == now.year &&
          o.updatedAt.month == now.month &&
          o.updatedAt.day == now.day;
    }).length;
  }

  List<OrderModel> get recentOrders {
    final list = List<OrderModel>.from(_orderController.allOrders);
    list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return list.take(5).toList();
  }
}
