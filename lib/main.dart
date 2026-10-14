import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/app_env.dart';
import 'core/theme/app_theme.dart';
import 'data/services/firebase_service.dart';
import 'data/services/firestore_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/worker_controller.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await AppEnv.init();

  // Initialize Firebase with offline persistence & fallback
  await FirebaseService.initialize();

  // Dependency Injection using GetX Clean Architecture
  Get.put<FirestoreService>(FirestoreService(), permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<CustomerController>(CustomerController(), permanent: true);
  Get.put<OrderController>(OrderController(), permanent: true);
  Get.put<DashboardController>(DashboardController(), permanent: true);
  Get.put<WorkerController>(WorkerController(), permanent: true);

  runApp(const StitchUpApp());
}

class StitchUpApp extends StatelessWidget {
  const StitchUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'StitchUp – Tailor Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeCtrl.themeMode.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 320),
      );
    });
  }
}
