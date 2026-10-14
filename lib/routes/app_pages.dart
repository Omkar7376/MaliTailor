import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/customers/customers_view.dart';
import '../views/customers/customer_detail_view.dart';
import '../views/customers/add_customer_view.dart';
import '../views/orders/orders_view.dart';
import '../views/orders/new_order_view.dart';
import '../views/orders/order_detail_view.dart';
import '../views/workers/workers_view.dart';
import '../views/analytics/analytics_view.dart';
import '../views/invoices/invoice_view.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.customerDetail,
      page: () => const CustomerDetailView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.addCustomer,
      page: () => const AddCustomerView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.newOrder,
      page: () => const NewOrderView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.workers,
      page: () => const WorkersView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.invoice,
      page: () => const InvoiceView(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
    ),
  ];
}
