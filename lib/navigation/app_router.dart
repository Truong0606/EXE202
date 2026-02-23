import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/screens/auth/login_prototype_page.dart';
import 'package:first_app/screens/auth/register_page.dart';
import 'package:first_app/screens/onboarding/forgot_record_prompt_page.dart';
import 'package:first_app/screens/onboarding/onboarding_intro_page.dart';
import 'package:first_app/screens/onboarding/user_group_selection_page.dart';
import 'package:first_app/screens/profile/medical_profile_setup_page.dart';
import 'package:first_app/screens/profile/profile_greeting_page.dart';
import 'package:flutter/material.dart';

class RegisterRouteArgs {
  const RegisterRouteArgs({
    this.title = 'Đăng ký tài khoản mới',
    this.continueToProfileSetup = true,
  });

  final String title;
  final bool continueToProfileSetup;
}

class ProfileGreetingRouteArgs {
  const ProfileGreetingRouteArgs({required this.name});

  final String name;
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPrototypePage(),
          settings: settings,
        );
      case AppRoutes.register:
        final RegisterRouteArgs args =
            (settings.arguments as RegisterRouteArgs?) ??
            const RegisterRouteArgs();
        return MaterialPageRoute<void>(
          builder: (_) => RegisterPage(
            title: args.title,
            continueToProfileSetup: args.continueToProfileSetup,
          ),
          settings: settings,
        );
      case AppRoutes.medicalProfileSetup:
        return _buildFadeRoute(
          settings: settings,
          child: const MedicalProfileSetupPage(),
        );
      case AppRoutes.profileGreeting:
        final ProfileGreetingRouteArgs args =
            settings.arguments as ProfileGreetingRouteArgs;
        return _buildFadeRoute(
          settings: settings,
          child: ProfileGreetingPage(name: args.name),
        );
      case AppRoutes.onboardingIntro:
        return _buildFadeRoute(
          settings: settings,
          child: const OnboardingIntroPage(),
        );
      case AppRoutes.userGroupSelection:
        return _buildFadeRoute(
          settings: settings,
          child: const UserGroupSelectionPage(),
        );
      case AppRoutes.forgotRecordPrompt:
        return _buildFadeRoute(
          settings: settings,
          child: const ForgotRecordPromptPage(),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPrototypePage(),
          settings: settings,
        );
    }
  }

  static Route<dynamic> _buildFadeRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
