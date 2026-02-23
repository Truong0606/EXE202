import 'package:first_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppButtonStyles {
  static ButtonStyle smallAuth({required double horizontalPadding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
      elevation: 0,
    );
  }

  static ButtonStyle primaryPill({
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      disabledBackgroundColor: disabledBackgroundColor,
      foregroundColor: Colors.white,
      disabledForegroundColor: disabledForegroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12),
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
    );
  }

  const AppButtonStyles._();
}
