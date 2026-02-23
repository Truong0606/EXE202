import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class TrackEasyBenefitsPage extends StatelessWidget {
  const TrackEasyBenefitsPage({super.key});

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
                'GlucoDia giúp bạn theo dõi\ndễ dàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 28),
              const _BenefitItem(
                icon: '💧',
                text: 'Tự động ghi nhận chỉ số',
              ),
              const SizedBox(height: 14),
              const _BenefitItem(
                icon: '🔔',
                text: 'Nhắc nhở uống thuốc và kiểm tra',
              ),
              const SizedBox(height: 14),
              const _BenefitItem(
                icon: '📊',
                text: 'Chia sẻ báo cáo cho bác sĩ',
              ),
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/onboarding_track_easy.png',
                fit: BoxFit.contain,
                height: 220,
              ),
              const Spacer(),
              PrimaryPillButton(
                label: 'Tiếp tục',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.doctorsTrust);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
