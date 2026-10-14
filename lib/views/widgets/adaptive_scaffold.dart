import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../routes/app_routes.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int currentIndex;
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.onRefresh,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  bool isSidebarCollapsed = false;

  void _onNavigate(int index) {
    if (index == widget.currentIndex) return;
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.dashboard);
        break;
      case 1:
        Get.offNamed(AppRoutes.customers);
        break;
      case 2:
        Get.offNamed(AppRoutes.orders);
        break;
      case 3:
        Get.offNamed(AppRoutes.workers);
        break;
      case 4:
        Get.offNamed(AppRoutes.analytics);
        break;
    }
  }

  Future<void> _handleGlobalRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
      return;
    }
    // Default refresh: refreshes all active GetX controllers and streams
    try {
      if (Get.isRegistered<OrderController>()) {
        await Get.find<OrderController>().refreshOrders();
      }
      if (Get.isRegistered<CustomerController>()) {
        await Get.find<CustomerController>().refreshCustomers();
      }
      if (Get.isRegistered<WorkerController>()) {
        await Get.find<WorkerController>().refreshWorkers();
      }
      Get.snackbar(
        'Refreshed',
        'All modules updated with real-time data',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.accentLightBrown.withAlpha(220),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {}
  }

  void _showConfirmResetDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('Reset All Records?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all orders, customers, and staff transaction records from Cloud Firestore so you can start completely fresh.\n\nYour admin details and shop settings will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await authController.resetAllDataExceptAdmin();
              await _handleGlobalRefresh();
            },
            child: const Text('Reset & Start Fresh'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final isTablet = AdaptiveLayout.isTablet(context);
    final isSmallMobile = AdaptiveLayout.isSmallMobile(context);
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    final refreshButton = IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Refresh Data',
      onPressed: _handleGlobalRefresh,
    );

    final effectiveBody = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: RefreshIndicator(
        key: ValueKey<int>(widget.currentIndex),
        onRefresh: _handleGlobalRefresh,
        color: AppColors.accentLightBrown,
        child: widget.body,
      ),
    );

    final navItems = [
      _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Home'),
      _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Customers'),
      _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Orders'),
      _NavItem(icon: Icons.badge_outlined, activeIcon: Icons.badge_rounded, label: 'Staff'),
      _NavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, label: 'Analysis'),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Desktop Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSidebarCollapsed ? 80 : 260,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.primaryDarkBrown,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Brand Header
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentLightBrown,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.cut, color: Colors.white, size: 22),
                        ),
                        if (!isSidebarCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'StitchUp',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Tailor Management',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.softGolden,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // "New Order" Action Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.newOrder),
                      icon: const Icon(Icons.add, size: 18),
                      label: isSidebarCollapsed ? const SizedBox.shrink() : const Text('New Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLightBrown,
                        foregroundColor: AppColors.primaryDarkBrown,
                        minimumSize: Size(isSidebarCollapsed ? 48 : double.infinity, 44),
                        padding: EdgeInsets.symmetric(horizontal: isSidebarCollapsed ? 0 : 16),
                      ),
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 24),

                  // Menu Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: navItems.length,
                      itemBuilder: (context, i) {
                        final item = navItems[i];
                        final isSelected = widget.currentIndex == i;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: InkWell(
                            onTap: () => _onNavigate(i),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppColors.darkSurfaceCard : Colors.white.withAlpha(30))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(color: AppColors.accentLightBrown.withAlpha(120))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    color: isSelected ? AppColors.accentLightBrown : Colors.white70,
                                    size: 22,
                                  ),
                                  if (!isSidebarCollapsed) ...[
                                    const SizedBox(width: 14),
                                    Text(
                                      item.label,
                                      style: GoogleFonts.poppins(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Footer Controls (Collapse, Theme, Tailor Profile)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Theme Toggle & Collapse
                        if (isSidebarCollapsed)
                          Column(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                tooltip: 'Toggle Theme',
                                onPressed: () => themeController.toggleTheme(),
                                icon: Icon(
                                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                tooltip: 'Expand Sidebar',
                                onPressed: () {
                                  setState(() {
                                    isSidebarCollapsed = !isSidebarCollapsed;
                                  });
                                },
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                tooltip: 'Toggle Theme',
                                onPressed: () => themeController.toggleTheme(),
                                icon: Icon(
                                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Collapse Sidebar',
                                onPressed: () {
                                  setState(() {
                                    isSidebarCollapsed = !isSidebarCollapsed;
                                  });
                                },
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        // Current User Profile
                        Obx(() {
                          final tailor = authController.currentTailor.value ?? AuthController.defaultTailor;
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isSidebarCollapsed
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
                                    tooltip: 'Logout (${tailor.shopName})',
                                    onPressed: () => authController.logout(),
                                  )
                                : Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.accentLightBrown,
                                        child: Text(
                                          tailor.ownerName.isNotEmpty ? tailor.ownerName[0].toUpperCase() : 'T',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tailor.shopName,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              tailor.ownerName,
                                              style: GoogleFonts.poppins(
                                                color: AppColors.softGolden,
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.orangeAccent, size: 17),
                                        tooltip: 'Reset Database (Keep Admin)',
                                        onPressed: () => _showConfirmResetDialog(context, authController),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.logout, color: Colors.white70, size: 16),
                                        tooltip: 'Logout',
                                        onPressed: () => authController.logout(),
                                      ),
                                    ],
                                  ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Desktop Main Body
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                  actions: [
                    refreshButton,
                    ...?widget.actions,
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                      onPressed: () => themeController.toggleTheme(),
                    ),
                  ],
                ),
                body: effectiveBody,
                floatingActionButton: widget.floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            refreshButton,
            ...?widget.actions,
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: () => themeController.toggleTheme(),
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.currentIndex.clamp(0, 4),
              onDestinationSelected: _onNavigate,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              selectedIconTheme: const IconThemeData(color: AppColors.accentLightBrown),
              unselectedIconTheme: IconThemeData(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              labelType: NavigationRailLabelType.all,
              destinations: navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: effectiveBody),
          ],
        ),
        floatingActionButton: widget.floatingActionButton ??
            FloatingActionButton.extended(
              onPressed: () => Get.toNamed(AppRoutes.newOrder),
              icon: const Icon(Icons.add),
              label: const Text('Order'),
              backgroundColor: AppColors.accentLightBrown,
              foregroundColor: AppColors.primaryDarkBrown,
            ),
      );
    }

    // Mobile (< 600px)
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: isSmallMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          refreshButton,
          ...?widget.actions,
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryDarkBrown,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentLightBrown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cut, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mali Tailors',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Obx(() {
                    final tailor = authController.currentTailor.value;
                    return Text(
                      tailor?.shopName ?? 'Tailor Management',
                      style: GoogleFonts.poppins(color: AppColors.softGolden, fontSize: 12),
                    );
                  }),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: widget.currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onNavigate(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Customers'),
              selected: widget.currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onNavigate(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Orders'),
              selected: widget.currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onNavigate(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Workshop Staff'),
              selected: widget.currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _onNavigate(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Accounts & Income'),
              selected: widget.currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _onNavigate(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.orangeAccent),
              title: const Text('Reset Database', style: TextStyle(color: Colors.orangeAccent)),
              subtitle: const Text('Keep admin details, clear records', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                _showConfirmResetDialog(context, authController);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                authController.logout();
              },
            ),
          ],
        ),
      ),
      body: effectiveBody,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 8 : 14,
            vertical: isSmallMobile ? 6 : 8,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 4 : 8,
            vertical: isSmallMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F1A15).withAlpha(245)
                : Colors.white.withAlpha(245),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.softGolden.withAlpha(35)
                  : AppColors.accentLightBrown.withAlpha(60),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 25),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = widget.currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onNavigate(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallMobile ? 5 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.softGolden.withAlpha(38)
                              : AppColors.primaryDarkBrown.withAlpha(22))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: isSmallMobile ? 20 : 22,
                            color: isSelected
                                ? (isDark ? AppColors.softGolden : AppColors.primaryDarkBrown)
                                : (isDark ? Colors.white60 : Colors.black45),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallMobile ? 9.5 : 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? AppColors.softGolden : AppColors.primaryDarkBrown)
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Animated dot indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutQuad,
                          width: isSelected ? (isSmallMobile ? 12 : 16) : 0,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.softGolden : AppColors.primaryDarkBrown)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      floatingActionButton: widget.floatingActionButton ??
          FloatingActionButton(
            onPressed: () => Get.toNamed(AppRoutes.newOrder),
            backgroundColor: AppColors.accentLightBrown,
            foregroundColor: AppColors.primaryDarkBrown,
            child: const Icon(Icons.add),
          ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
