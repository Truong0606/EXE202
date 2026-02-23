import 'package:first_app/core/theme/app_button_styles.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.primaryPill(
          disabledBackgroundColor:
              disabledBackgroundColor ?? AppColors.disabledButton,
          disabledForegroundColor:
              disabledForegroundColor ?? AppColors.disabledText,
        ),
        child: Text(
          label,
          style: AppTextStyles.primaryButtonLabel,
        ),
      ),
    );
  }
}
