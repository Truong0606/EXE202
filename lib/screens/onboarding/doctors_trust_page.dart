import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class DoctorsTrustPage extends StatelessWidget {
  const DoctorsTrustPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 28),
              const Text(
                'Được phát triển\ncùng bác sĩ nội tiết',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Bảo mật – Chính xác – Phù hợp người dùng\nViệt Nam',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.deepBlue,
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFFFFC94A),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verified by Doctors VN',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Image.asset(
                'assets/images/onboarding_doctors_mascot.png',
                fit: BoxFit.contain,
                height: 210,
              ),
              const Spacer(),
              const Text(
                'Dữ liệu của bạn được mã hóa và chỉ chia sẻ khi\nbạn đồng ý.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryPillButton(
                label: 'Tiếp tục',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.readyStart);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
