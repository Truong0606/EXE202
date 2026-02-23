import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class ReadyStartPage extends StatelessWidget {
  const ReadyStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 52),
              const Text(
                'Sẵn sàng bắt đầu hành trình\nkhỏe mạnh?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 66),
              Image.asset(
                'assets/images/onboarding_ready_start.png',
                fit: BoxFit.contain,
                height: 300,
              ),
              const Spacer(),
              PrimaryPillButton(
                label: 'Bắt đầu ngay',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.lightBlue,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Tôi muốn xem thử',
                    style: TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
