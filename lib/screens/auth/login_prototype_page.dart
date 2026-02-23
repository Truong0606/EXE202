import 'package:first_app/core/theme/app_button_styles.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/navigation/app_router.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/core/widgets/glucare_brand_header.dart';
import 'package:flutter/material.dart';

class LoginPrototypePage extends StatelessWidget {
  const LoginPrototypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GluCareBrandHeader(
                  logoWidth: 190,
                  textWidth: 140,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.register,
                          arguments: const RegisterRouteArgs(
                            title: 'Đăng nhập',
                            continueToProfileSetup: false,
                          ),
                        );
                      },
                      style: AppButtonStyles.smallAuth(horizontalPadding: 18),
                      child: const Text('Đăng nhập'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.register);
                      },
                      style: AppButtonStyles.smallAuth(horizontalPadding: 22),
                      child: const Text('Đăng ký'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
