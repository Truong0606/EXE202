import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:flutter/material.dart';

class OnboardingIntroPage extends StatelessWidget {
  const OnboardingIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Chào mừng đến với',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'GlucoDia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 56,
                          height: 1.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ứng dụng hỗ trợ quản lý đường huyết',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mutedBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: AspectRatio(
                          aspectRatio: 1.12,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: AppColors.onboardingCircle,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/glucare_logo.png',
                                      width: 190,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 20,
                                bottom: -2,
                                child: Image.asset(
                                  'assets/images/mascot_talk_4.png',
                                  width: 86,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryPillButton(
                label: 'Bắt đầu',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.userGroupSelection);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
