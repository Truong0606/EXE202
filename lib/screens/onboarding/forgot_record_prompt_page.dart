import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class ForgotRecordPromptPage extends StatelessWidget {
  const ForgotRecordPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Bạn thường quên\nghi lại chỉ số?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Việc theo dõi đường huyết bằng tay\ndễ gây thiếu sót.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Image.asset(
                'assets/images/onboarding_forget_measure.png',
                fit: BoxFit.contain,
                height: 300,
              ),
              const Spacer(),
              PrimaryPillButton(
                label: 'Tiếp tục',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.trackEasyBenefits);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
