import 'package:first_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 24,
  );

  static const TextStyle primaryButtonLabel = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.primaryBlue,
    fontSize: 46,
    fontWeight: FontWeight.w700,
  );

  const AppTextStyles._();
}
