import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class MeasurementInputCard extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String hint;

  const MeasurementInputCard({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint = '0.0',
  });

  @override
  State<MeasurementInputCard> createState() => _MeasurementInputCardState();
}

class _MeasurementInputCardState extends State<MeasurementInputCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant MeasurementInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjust(double delta) {
    double current = double.tryParse(_controller.text) ?? 0.0;
    current += delta;
    if (current < 0) current = 0;
    final formatted = current.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
    _controller.text = formatted;
    widget.onChanged(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.softGolden : AppColors.secondaryMediumBrown,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'inches',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDarkBrown,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    onChanged: (text) {
                      widget.onChanged(text);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Incremental Adjustment Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _quickButton(context, '-.5', () => _adjust(-0.5)),
                  const SizedBox(width: 3),
                  _quickButton(context, '+.5', () => _adjust(0.5)),
                  const SizedBox(width: 3),
                  _quickButton(context, '+¼', () => _adjust(0.25)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickButton(BuildContext context, String text, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 28,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(26, 26),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
            color: isDark
                ? AppColors.accentLightBrown.withAlpha(120)
                : AppColors.accentLightBrown.withAlpha(160),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.softGolden : AppColors.secondaryMediumBrown,
          ),
        ),
      ),
    );
  }
}
