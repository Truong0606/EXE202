class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String medicalProfileSetup = '/medical-profile-setup';
  static const String profileGreeting = '/profile-greeting';
  static const String onboardingIntro = '/onboarding-intro';
  static const String userGroupSelection = '/user-group-selection';
  static const String forgotRecordPrompt = '/forgot-record-prompt';
  static const String trackEasyBenefits = '/track-easy-benefits';
  static const String doctorsTrust = '/doctors-trust';
  static const String readyStart = '/ready-start';
  static const String home = '/home';
  static const String glucose24hDetail = '/glucose-24h-detail';
}

class HomeRouteArgs {
  const HomeRouteArgs({this.initialTabIndex = 0});

  final int initialTabIndex;
}
