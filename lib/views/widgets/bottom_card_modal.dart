import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/responsive/adaptive_layout.dart';

/// Shows a smooth bottom-to-up sliding card on mobile or responsive sheet on web/desktop.
Future<T?> showBottomUpCard<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  double maxHeightFactor = 0.92,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isMobile = AdaptiveLayout.isMobile(context);

  if (isMobile) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: maxHeightFactor,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Column(
                  children: [
                    // Drag Handle Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(child: builder(ctx)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  } else {
    // Desktop / Web: Centered dialog with responsive maximum constraints
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: MediaQuery.of(ctx).size.height * maxHeightFactor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: builder(ctx),
            ),
          ),
        );
      },
    );
  }
}
