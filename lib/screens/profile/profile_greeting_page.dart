import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/core/widgets/glucare_brand_header.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:flutter/material.dart';

class ProfileGreetingPage extends StatelessWidget {
  const ProfileGreetingPage({
    required this.name,
    super.key,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thiết lập hồ sơ bệnh án',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const GluCareBrandHeader(
                logoWidth: 150,
                textWidth: 190,
                gap: 10,
              ),
              const SizedBox(height: 140),
              const Text(
                'Xin chào!',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 58,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 210),
              PrimaryPillButton(
                label: 'Tiếp theo',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.onboardingIntro);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
