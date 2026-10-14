import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.accentLightBrown,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isSmall = width <= 380;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 16,
            vertical: isSmall ? 10 : 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmall ? 6 : 8),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(isDark ? 50 : 30),
                      borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
                    ),
                    child: Icon(icon, color: accentColor, size: isSmall ? 16 : 20),
                  ),
                  if (subtitle != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: isSmall ? 9 : 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: isSmall ? 4 : 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 20 : 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 10.5 : 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
