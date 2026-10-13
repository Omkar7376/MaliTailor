import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        color = AppColors.statusPending;
        bgColor = AppColors.statusPending.withAlpha(30);
        break;
      case 'in progress':
        color = AppColors.statusInProgress;
        bgColor = AppColors.statusInProgress.withAlpha(30);
        break;
      case 'ready':
        color = AppColors.statusReady;
        bgColor = AppColors.statusReady.withAlpha(30);
        break;
      case 'delivered':
        color = AppColors.statusDelivered;
        bgColor = AppColors.statusDelivered.withAlpha(30);
        break;
      case 'cancelled':
        color = AppColors.statusCancelled;
        bgColor = AppColors.statusCancelled.withAlpha(30);
        break;
      default:
        color = AppColors.secondaryMediumBrown;
        bgColor = AppColors.secondaryMediumBrown.withAlpha(30);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
