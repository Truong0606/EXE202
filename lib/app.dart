import 'package:first_app/core/theme/app_theme.dart';
import 'package:first_app/navigation/app_router.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class GluCareApp extends StatelessWidget {
  const GluCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
