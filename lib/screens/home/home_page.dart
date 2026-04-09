import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:first_app/core/models/dashboard_models.dart';
import 'package:first_app/core/services/account_settings_service.dart';
import 'package:first_app/core/services/auth_storage_service.dart';
import 'package:first_app/core/services/backend_api_service.dart';
import 'package:first_app/core/services/notification_service.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'home_page_extras.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<File?> _pickAvatarFileWithCrop(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? selectedFile = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    imageQuality: 92,
  );
  if (selectedFile == null) {
    return null;
  }

  if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    return File(selectedFile.path);
  }

  if (!context.mounted) {
    return null;
  }

  final List<PlatformUiSettings> uiSettings = <PlatformUiSettings>[
    if (!kIsWeb && Platform.isAndroid)
      AndroidUiSettings(
        toolbarTitle: 'Cắt ảnh đại diện',
        toolbarColor: AppColors.primaryBlue,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: AppColors.primaryBlue,
        cropStyle: CropStyle.circle,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
    if (!kIsWeb && Platform.isIOS)
      IOSUiSettings(
        title: 'Cắt ảnh đại diện',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
        rectX: 1,
        rectY: 1,
        rectWidth: 1,
        rectHeight: 1,
      ),
    if (kIsWeb)
      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
        size: const CropperSize(width: 420, height: 520),
      ),
  ];

  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: selectedFile.path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 88,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    uiSettings: uiSettings,
  );

  if (croppedFile == null) {
    return null;
  }

  return File(croppedFile.path);
}

class _HomePageState extends State<HomePage> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  final AccountSettingsService _accountSettingsService =
      AccountSettingsService.instance;

  late int currentTabIndex;
  bool _hasShownPaymentPromo = false;
  bool _isCheckingPaymentPromo = false;
  String _displayName = 'GluCare';
  UserProfileData? _currentUserProfile;
  List<BlogArticleData> _blogArticles = const <BlogArticleData>[];
  String? _blogArticleErrorMessage;
  bool _isLoadingBlogArticle = true;
  List<FollowMemberData> _followMembers = const <FollowMemberData>[];

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialTabIndex.clamp(0, 4);
    unawaited(_initializeHome());
  }

  Future<void> _initializeHome() async {
    final bool hasSession = await _ensureAuthenticatedSession();
    if (!hasSession) {
      return;
    }

    await Future.wait<void>(<Future<void>>[
      _loadDashboardApiData(),
      _loadCurrentUserProfile(),
    ]);
  }

  Future<void> _loadCurrentUserProfile() async {
    final UserProfileData? userProfile = await _backendApiService
        .fetchCurrentUserProfile();
    if (!mounted || userProfile == null) {
      return;
    }

    final String fullName = userProfile.fullName.trim();
    setState(() {
      _currentUserProfile = userProfile;
      if (fullName.isNotEmpty) {
        _displayName = fullName;
      }
    });

    unawaited(_maybeShowPaymentPromo());
  }

  void _handleProfileUpdated(UserProfileData profile) {
    setState(() {
      _currentUserProfile = profile;
      if (profile.fullName.trim().isNotEmpty) {
        _displayName = profile.fullName.trim();
      }
    });

    unawaited(_maybeShowPaymentPromo());
  }

  Future<void> _openPaymentPage() async {
    final UserProfileData seedProfile =
        _currentUserProfile ??
        const UserProfileData(
          id: '',
          phoneNumber: '',
          role: 'PATIENT',
          fullName: '',
        );

    final UserProfileData? updatedProfile = await Navigator.of(context)
        .push<UserProfileData>(
          MaterialPageRoute<UserProfileData>(
            builder: (_) => _PaymentSettingsPage(profile: seedProfile),
          ),
        );
    if (!mounted || updatedProfile == null) {
      return;
    }

    _handleProfileUpdated(updatedProfile);
  }

  String _paymentPromoUserKey(UserProfileData profile) {
    final String userId = profile.id.trim();
    if (userId.isNotEmpty) {
      return userId;
    }
    return profile.phoneNumber.trim();
  }

  bool _hasLikelyActivePayment(List<PaymentHistoryItemData> history) {
    final DateTime now = DateTime.now();
    for (final PaymentHistoryItemData item in history) {
      final String normalizedPackageType =
          PaymentHistoryItemData.normalizePackageType(item.packageType);
      final bool lifetimeActive =
          normalizedPackageType == 'L' && item.status == 'SUCCESS';
      final bool expiryActive =
          item.expiresAt != null && item.expiresAt!.isAfter(now);
      if (item.isActive || lifetimeActive || expiryActive) {
        return true;
      }
    }

    return history.any(
      (PaymentHistoryItemData item) => item.status.toUpperCase() == 'SUCCESS',
    );
  }

  Future<void> _maybeShowPaymentPromo() async {
    final UserProfileData? profile = _currentUserProfile;
    if (_hasShownPaymentPromo ||
        _isCheckingPaymentPromo ||
        currentTabIndex != 0 ||
        profile == null) {
      return;
    }

    final String userKey = _paymentPromoUserKey(profile);
    if (userKey.isEmpty) {
      return;
    }

    _isCheckingPaymentPromo = true;
    final DateTime now = DateTime.now();

    try {
      final DateTime? lastShownAt = await _accountSettingsService
          .getPaymentPromoShownAt(userKey);
      if (lastShownAt != null &&
          now.difference(lastShownAt) < const Duration(days: 13)) {
        return;
      }

      final List<PaymentHistoryItemData> history = await _backendApiService
          .fetchPaymentHistory(page: 1, limit: 20);
      if (!mounted || _hasLikelyActivePayment(history)) {
        return;
      }

      _hasShownPaymentPromo = true;
      await _accountSettingsService.setPaymentPromoShownAt(userKey, now);
    } catch (_) {
      return;
    } finally {
      _isCheckingPaymentPromo = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final bool shouldOpenPayment =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
                title: Row(
                  children: [
                    const Expanded(child: Text('Nâng cấp Premium')),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Đóng',
                    ),
                  ],
                ),
                content: const Text(
                  'Mở khóa gói Premium để xem lịch sử thanh toán, theo dõi trạng thái kích hoạt và thanh toán ngay trong ứng dụng.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Để sau'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Xem gói Premium'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!mounted || !shouldOpenPayment) {
        return;
      }

      await _openPaymentPage();
    });
  }

  Future<bool> _ensureAuthenticatedSession() async {
    final String token =
        (await AuthStorageService.instance.getAccessToken())?.trim() ?? '';
    if (token.isNotEmpty) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    return false;
  }

  Future<void> _loadDashboardApiData() async {
    List<BlogArticleData> articles = const <BlogArticleData>[];
    String? blogArticleErrorMessage;
    List<FollowMemberData> members = const <FollowMemberData>[];

    try {
      articles = await _backendApiService.fetchPublishedBlogArticles();
    } catch (error) {
      blogArticleErrorMessage = error.toString().replaceFirst(
        'Exception: ',
        '',
      );
    }

    try {
      members = await _backendApiService.fetchFollowMembers();
    } catch (_) {}

    if (!mounted) {
      return;
    }

    setState(() {
      _blogArticles = articles;
      _blogArticleErrorMessage = blogArticleErrorMessage;
      _isLoadingBlogArticle = false;
      _followMembers = members;
    });
  }

  Future<void> _refreshHomeData() async {
    await Future.wait<void>(<Future<void>>[
      _loadDashboardApiData(),
      _loadCurrentUserProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF2FB),
      body: SafeArea(
        child: IndexedStack(
          index: currentTabIndex,
          children: [
            _DashboardTab(
              displayName: _displayName,
              onRefreshHomeData: _refreshHomeData,
              onOpenAiTab: () {
                setState(() {
                  currentTabIndex = 2;
                });
              },
            ),
            _DiaryTab(followMembers: _followMembers),
            _AiAssistantTab(
              onBackToHome: () {
                setState(() {
                  currentTabIndex = 0;
                });
              },
            ),
            _BlogTab(
              onBackToHome: () {
                setState(() {
                  currentTabIndex = 0;
                });
              },
              articles: _blogArticles,
              errorMessage: _blogArticleErrorMessage,
              isLoading: _isLoadingBlogArticle,
              onRetry: _refreshHomeData,
            ),
            _AccountTab(
              isActive: currentTabIndex == 4,
              profile: _currentUserProfile,
              onProfileUpdated: _handleProfileUpdated,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _HomeBottomNav(
        currentIndex: currentTabIndex,
        onSelected: (int index) {
          setState(() {
            currentTabIndex = index;
          });
          unawaited(_maybeShowPaymentPromo());
        },
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab({
    required this.onOpenAiTab,
    required this.displayName,
    required this.onRefreshHomeData,
  });

  final VoidCallback onOpenAiTab;
  final String displayName;
  final Future<void> Function() onRefreshHomeData;

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  static const int _glucoseGoalPercent = 50;
  static const int _weeklyGoalPercent = 40;
  final BackendApiService _backendApiService = BackendApiService.instance;

  DateTime selectedDate = DateTime.now();
  final List<double> _glucose24hPoints = <double>[];
  List<GlucoseHistoryItemData> _selectedDateRecords =
      const <GlucoseHistoryItemData>[];
  GlucoseHistoryItemData? _latestGlucoseHistory;
  double? _weeklyComplianceScore;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLatestGlucoseHistory());
    unawaited(_loadGlucoseGraph24hData());
    unawaited(_loadWeeklyComplianceScore());
    unawaited(_loadSelectedDateRecords());
    unawaited(
      NotificationService.instance.notifyWeeklyGoalReachedIfNeeded(
        glucoseGoalPercent: _glucoseGoalPercent,
        weeklyGoalPercent: _weeklyGoalPercent,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadLatestGlucoseHistory() async {
    final GlucoseHistoryItemData? latest = await _backendApiService
        .fetchLatestGlucoseHistory();
    if (!mounted) {
      return;
    }

    setState(() {
      _latestGlucoseHistory = latest;
    });
  }

  Future<void> _loadGlucoseGraph24hData() async {
    final List<GlucoseHistoryItemData> records = await _backendApiService
        .fetchGlucoseHistoryLast24Hours();
    if (!mounted) {
      return;
    }

    setState(() {
      _glucose24hPoints
        ..clear()
        ..addAll(
          records.map((GlucoseHistoryItemData item) => item.glucoseValue),
        );
    });
  }

  Future<void> _refreshGlucoseData() async {
    await Future.wait<void>(<Future<void>>[
      _loadLatestGlucoseHistory(),
      _loadGlucoseGraph24hData(),
      _loadWeeklyComplianceScore(),
      _loadSelectedDateRecords(),
    ]);
  }

  Future<void> _handleRefresh() async {
    await Future.wait<void>(<Future<void>>[
      _refreshGlucoseData(),
      widget.onRefreshHomeData(),
    ]);
  }

  Future<void> _loadSelectedDateRecords() async {
    final List<GlucoseHistoryItemData> records = await _backendApiService
        .fetchGlucoseHistoryByDate(selectedDate);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDateRecords = records.reversed.toList();
    });
  }

  Future<void> _loadWeeklyComplianceScore() async {
    final double? score = await _backendApiService.fetchWeeklyComplianceScore();
    if (!mounted) {
      return;
    }

    setState(() {
      _weeklyComplianceScore = score;
    });
  }

  String _formatScore(double? value) {
    if (value == null) {
      return '--';
    }
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _mealContextLabel(String mealContext) {
    switch (mealContext) {
      case 'BEFORE_MEAL':
        return 'Trước khi ăn';
      case 'AFTER_MEAL':
        return 'Sau khi ăn';
      case 'FASTING':
        return 'Lúc đói';
      case 'BEDTIME':
        return 'Trước khi ngủ';
      default:
        return 'Chưa xác định';
    }
  }

  String _formatRecordedAtLabel(DateTime recordedAt) {
    final DateTime localTime = recordedAt.toLocal();
    final int hour24 = localTime.hour;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String minute = localTime.minute.toString().padLeft(2, '0');
    final String meridiem = hour24 >= 12 ? 'PM' : 'AM';
    final String hour = hour12.toString().padLeft(2, '0');
    return '$hour:$minute $meridiem';
  }

  String _formatDayLabel(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatTimeOnly(DateTime date) {
    final DateTime local = date.toLocal();
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatGlucoseValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  Future<void> _pickSelectedDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Chọn ngày xem dữ liệu',
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
    await _loadSelectedDateRecords();
  }

  @override
  Widget build(BuildContext context) {
    final String latestGlucose = _latestGlucoseHistory == null
        ? '--'
        : _latestGlucoseHistory!.glucoseValue.round().toString();
    final String latestMealContext = _latestGlucoseHistory == null
        ? 'Chưa có dữ liệu'
        : _mealContextLabel(_latestGlucoseHistory!.mealContext);
    final String latestRecordedAtLabel = _latestGlucoseHistory == null
        ? '--:--'
        : _formatRecordedAtLabel(_latestGlucoseHistory!.recordedAt);
    final String weeklyScoreText = _formatScore(_weeklyComplianceScore);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.28, 0.73],
                  colors: [Color(0xFF1564A6), Color(0xFF07173A)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _SafeAssetImage(
                        path: 'assets/images/homepage/Mascot Hello 1 1.png',
                        width: 56,
                        height: 56,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Xin chào,\n${widget.displayName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_none,
                                color: Color(0xFF0D3A63),
                                size: 32,
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 11,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4D4F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
              color: const Color(0xFFDDF2FB),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x24000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: widget.onOpenAiTab,
                        child: Row(
                          children: [
                            const _SafeAssetImage(
                              path:
                                  'assets/images/homepage/Mascot Head 2 3.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Hỏi Cam Cam: Tôi nên ăn gì hôm nay?',
                                style: TextStyle(
                                  color: Color(0xFF6D8A9E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.mic,
                              color: Color(0xFF2D7FB4),
                              size: 23,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 160,
                          child: _HomeCard(
                            trailing: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFF73D4C7),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDDF2FB),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lượng đường đo gần nhất',
                                  style: TextStyle(
                                    color: Color(0xFF0B3159),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        latestGlucose,
                                        style: const TextStyle(
                                          color: Color(0xFF17324F),
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'mg/dL',
                                          style: TextStyle(
                                            color: Color(0xFF17324F),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$latestMealContext\nVào lúc $latestRecordedAtLabel',
                                  style: const TextStyle(
                                    color: Color(0xFF4F6780),
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 160,
                          child: _HomeCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Đường huyết trong 24h qua',
                                  style: TextStyle(
                                    color: Color(0xFF0B3159),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Center(
                                    child: _Glucose24hGraph(
                                      dataPoints: _glucose24hPoints,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.glucose24hDetail,
                                        arguments: List<double>.from(
                                          _glucose24hPoints,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Xem chi tiết →',
                                      style: TextStyle(
                                        color: AppColors.deepBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _HomeCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mục tiêu đường huyết',
                          style: TextStyle(
                            color: Color(0xFF0B3159),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: weeklyScoreText,
                                        style: const TextStyle(
                                          color: Color(0xFF17324F),
                                          fontSize: 44,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '%',
                                        style: TextStyle(
                                          color: Color(0xFF17324F),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Mục tiêu tuần này:  40%',
                                  style: TextStyle(
                                    color: Color(0xFF4F6780),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 74,
                                    height: 74,
                                    child: _AnimatedGoalHeart(
                                      score: _weeklyComplianceScore,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6FC8ED), Color(0xFF9BD9F4)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => QuickEntryPage(
                              onGlucoseSaved: _refreshGlucoseData,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _SafeAssetImage(
                            path: 'assets/images/homepage/Mascot Talk 1 1.png',
                            width: 32,
                            height: 32,
                          ),
                          Transform.translate(
                            offset: const Offset(-5, -4),
                            child: const _SafeAssetImage(
                              path:
                                  'assets/images/homepage/basil_camera-solid.png',
                              width: 12,
                              height: 12,
                            ),
                          ),
                          const Text(
                            'Bắt đầu đo',
                            style: TextStyle(
                              color: Color(0xFF12355A),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Theo dõi theo ngày',
                    style: TextStyle(
                      color: Color(0xFF12355A),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ngày đang xem',
                                    style: TextStyle(
                                      color: Color(0xFF5A7F99),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDayLabel(selectedDate),
                                    style: const TextStyle(
                                      color: Color(0xFF16395B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _pickSelectedDate,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6ECF8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Color(0xFF16395B),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedDateRecords.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6ECF8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Không có dữ liệu trong ngày này',
                              style: TextStyle(
                                color: Color(0xFF507089),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _selectedDateRecords.map((record) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6ECF8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatTimeOnly(record.recordedAt),
                                        style: const TextStyle(
                                          color: Color(0xFF16395B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _mealContextLabel(record.mealContext),
                                        style: const TextStyle(
                                          color: Color(0xFF4C718A),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_formatGlucoseValue(record.glucoseValue)} mg/dL',
                                      style: const TextStyle(
                                        color: Color(0xFF16395B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child, this.trailing});

  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _Glucose24hGraph extends StatelessWidget {
  const _Glucose24hGraph({required this.dataPoints});

  final List<double> dataPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD0DEE6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _Glucose24hGraphPainter(dataPoints: dataPoints),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glucose24hGraphPainter extends CustomPainter {
  const _Glucose24hGraphPainter({required this.dataPoints});

  final List<double> dataPoints;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect clipRRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(10),
    );

    canvas.save();
    canvas.clipRRect(clipRRect);

    final Paint bgPaint = Paint()..color = const Color(0xFFB9D0DD);
    canvas.drawRect(rect, bgPaint);

    final Paint gridPaint = Paint()
      ..color = const Color(0x66779AAF)
      ..strokeWidth = 1;

    const double step = 12;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (dataPoints.isEmpty) {
      final Path mountainFillPath = Path()
        ..moveTo(0, size.height * 0.78)
        ..lineTo(size.width * 0.34, size.height * 0.42)
        ..lineTo(size.width * 0.58, size.height * 0.58)
        ..lineTo(size.width * 0.93, size.height * 0.18)
        ..lineTo(size.width, size.height * 0.1)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final Paint mountainFillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xBB58C9CC), Color(0xCC1F6D97), Color(0xEE0B1E4C)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect);

      final Path mountainLinePath = Path()
        ..moveTo(0, size.height * 0.78)
        ..lineTo(size.width * 0.34, size.height * 0.42)
        ..lineTo(size.width * 0.58, size.height * 0.58)
        ..lineTo(size.width * 0.93, size.height * 0.18)
        ..lineTo(size.width, size.height * 0.1);

      final Paint mountainLinePaint = Paint()
        ..color = const Color(0xFF2E7B95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(mountainFillPath, mountainFillPaint);
      canvas.drawPath(mountainLinePath, mountainLinePaint);

      final Paint rightShadePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            const Color(0x33071936),
            const Color(0x66071936),
          ],
          stops: const [0.58, 0.82, 1.0],
        ).createShader(rect);
      canvas.drawRect(rect, rightShadePaint);
    } else {
      final double minValue = dataPoints.reduce(math.min);
      final double maxValue = dataPoints.reduce(math.max);
      final double range = (maxValue - minValue).abs() < 0.0001
          ? 1
          : (maxValue - minValue);

      final Path linePath = Path();
      final Path fillPath = Path();

      for (int i = 0; i < dataPoints.length; i++) {
        final double t = dataPoints.length == 1
            ? 0
            : i / (dataPoints.length - 1);
        final double x = t * size.width;
        final double normalized = (dataPoints[i] - minValue) / range;
        final double y = size.height - (normalized * (size.height - 10)) - 5;

        if (i == 0) {
          linePath.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          linePath.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      final Paint fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x8833B5B5), Color(0x1133B5B5)],
        ).createShader(rect);

      final Paint linePaint = Paint()
        ..color = const Color(0xFF2E8AA5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Glucose24hGraphPainter oldDelegate) {
    if (oldDelegate.dataPoints.length != dataPoints.length) {
      return true;
    }
    for (int i = 0; i < dataPoints.length; i++) {
      if (oldDelegate.dataPoints[i] != dataPoints[i]) {
        return true;
      }
    }
    return false;
  }
}

class _AnimatedGoalHeart extends StatefulWidget {
  const _AnimatedGoalHeart({required this.score});

  final double? score;

  @override
  State<_AnimatedGoalHeart> createState() => _AnimatedGoalHeartState();
}

class _AnimatedGoalHeartState extends State<_AnimatedGoalHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _normalizedScore => ((widget.score ?? 0) / 100).clamp(0.0, 1.0);

  void _updateAnimationProfile() {
    final Duration duration = Duration(
      milliseconds: (1450 - (_normalizedScore * 550)).round(),
    );
    _controller.duration = duration;
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _updateAnimationProfile();
  }

  @override
  void didUpdateWidget(covariant _AnimatedGoalHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _updateAnimationProfile();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double normalizedScore = _normalizedScore;
    final Color glowColor =
        Color.lerp(
          const Color(0xFFF7B7B7),
          const Color(0xFFEE5D6C),
          normalizedScore,
        ) ??
        const Color(0xFFEE5D6C);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double pulse = Curves.easeInOut.transform(_controller.value);
        final double scale =
            (0.9 + (normalizedScore * 0.05)) +
            (pulse * (0.08 + (normalizedScore * 0.1)));
        final double glowAlpha =
            0.18 + (normalizedScore * 0.18) + (pulse * 0.12);
        final double blurRadius = 8 + (normalizedScore * 8) + (pulse * 8);
        final double spreadRadius =
            0.5 + (normalizedScore * 1.5) + (pulse * 1.5);
        final double heartFill =
            0.2 + (normalizedScore * 0.45) + (pulse * 0.25);

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.94),
                  const Color(0xFFFFE8EC),
                  const Color(0xFFF7B7B7),
                ],
                stops: const [0.0, 0.58, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(
                    alpha: glowAlpha.clamp(0.0, 0.55),
                  ),
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.favorite_rounded,
                size: 42,
                color:
                    Color.lerp(
                      const Color(0xFFE97B8E),
                      const Color(0xFFD83552),
                      heartFill.clamp(0.0, 1.0),
                    ) ??
                    const Color(0xFFD83552),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home, 'Trang chủ'),
      (Icons.list_alt_outlined, Icons.list_alt, 'Nhật ký'),
      (Icons.psychology_alt_outlined, Icons.psychology_alt, 'Trợ lý AI'),
      (Icons.library_books_outlined, Icons.library_books, 'Blog'),
      (Icons.person_outline, Icons.person, 'Tài khoản'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.28, 0.73],
            colors: [Color(0xFF1564A6), Color(0xFF07173A)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                for (int i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onSelected(i),
                      child: Builder(
                        builder: (context) {
                          final bool isSelected = i == currentIndex;
                          final bool isAiTab = i == 2;

                          final Widget navContent = Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isAiTab)
                                const SizedBox(height: 24)
                              else ...[
                                Icon(
                                  isSelected ? items[i].$2 : items[i].$1,
                                  color: isSelected
                                      ? const Color(0xFF1D4670)
                                      : const Color(0xFFD6E3F1),
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                items[i].$3,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF1D4670)
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          );

                          if (isSelected) {
                            return Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: navContent,
                            );
                          }

                          return navContent;
                        },
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -8,
              child: IgnorePointer(
                ignoring: true,
                child: Center(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: const _SafeAssetImage(
                      path: 'assets/images/homepage/Mascot Head 2 3.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTab extends StatefulWidget {
  const _AccountTab({
    required this.isActive,
    this.profile,
    required this.onProfileUpdated,
  });

  final bool isActive;
  final UserProfileData? profile;
  final ValueChanged<UserProfileData> onProfileUpdated;

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  final AccountSettingsService _accountSettingsService =
      AccountSettingsService.instance;

  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;
  bool _isUploadingAvatar = false;
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  bool _isProfileMessageError = false;
  String? _profileMessage;
  _PremiumProfileTitleData? _premiumTitle;
  UserProfileData? _profile;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettingsState());
  }

  @override
  void didUpdateWidget(covariant _AccountTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      setState(() {
        _profile = widget.profile;
        _isLoadingProfile = false;
      });
      unawaited(_loadPremiumTitle());
      return;
    }

    if (!oldWidget.isActive && widget.isActive) {
      unawaited(_loadPremiumTitle());
    }
  }

  Future<void> _loadSettingsState() async {
    final bool notificationsEnabled = await _accountSettingsService
        .getNotificationsEnabled();
    final bool remindersEnabled = await _accountSettingsService
        .getRemindersEnabled();
    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _remindersEnabled = remindersEnabled;
      _profile = widget.profile;
      _isLoadingProfile = false;
    });

    unawaited(_loadPremiumTitle());
  }

  Future<void> _loadPremiumTitle() async {
    final UserProfileData? profile = _profile ?? widget.profile;
    if (profile == null) {
      if (mounted) {
        setState(() {
          _premiumTitle = null;
        });
      }
      return;
    }

    try {
      final List<PaymentHistoryItemData> history = await _backendApiService
          .fetchPaymentHistory(page: 1, limit: 20);
      if (!mounted) {
        return;
      }

      setState(() {
        _premiumTitle = _derivePremiumProfileTitle(history);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _premiumTitle = null;
      });
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthStorageService.instance.clearSession();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) {
      return;
    }

    final bool shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text(
                'Bạn có chắc muốn đăng xuất khỏi tài khoản này không?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Ở lại'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout) {
      return;
    }

    await _logout();
  }

  Future<void> _openPhoneSettings() async {
    await openAppSettings();
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _accountSettingsService.setNotificationsEnabled(value);
  }

  Future<void> _setRemindersEnabled(bool value) async {
    setState(() {
      _remindersEnabled = value;
    });
    await _accountSettingsService.setRemindersEnabled(value);
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) {
      return;
    }

    final File? avatarFile = await _pickAvatarFileWithCrop(context);
    if (avatarFile == null) {
      return;
    }

    setState(() {
      _isUploadingAvatar = true;
      _profileMessage = null;
      _isProfileMessageError = false;
    });

    try {
      final UserProfileData? updatedProfile = await _backendApiService
          .uploadProfileAvatar(avatarFile);
      if (!mounted) {
        return;
      }

      if (updatedProfile != null) {
        widget.onProfileUpdated(updatedProfile);
      }

      setState(() {
        _profile = updatedProfile ?? _profile;
        _profileMessage = 'Ảnh đại diện đã được cập nhật.';
        _isProfileMessageError = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileMessage = error.toString().replaceFirst('Exception: ', '');
        _isProfileMessageError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _openEditProfilePage() async {
    final UserProfileData seedProfile =
        _profile ??
        const UserProfileData(
          id: '',
          phoneNumber: '',
          role: 'PATIENT',
          fullName: '',
        );

    final UserProfileData? updatedProfile = await Navigator.of(context)
        .push<UserProfileData>(
          MaterialPageRoute<UserProfileData>(
            builder: (_) =>
                _EditAccountProfilePage(initialProfile: seedProfile),
          ),
        );
    if (!mounted || updatedProfile == null) {
      return;
    }

    setState(() {
      _profile = updatedProfile;
    });
    widget.onProfileUpdated(updatedProfile);
  }

  Future<void> _openPaymentPage() async {
    final UserProfileData seedProfile =
        _profile ??
        const UserProfileData(
          id: '',
          phoneNumber: '',
          role: 'PATIENT',
          fullName: '',
        );

    final UserProfileData? updatedProfile = await Navigator.of(context)
        .push<UserProfileData>(
          MaterialPageRoute<UserProfileData>(
            builder: (_) => _PaymentSettingsPage(profile: seedProfile),
          ),
        );
    if (!mounted) {
      return;
    }

    if (updatedProfile != null) {
      setState(() {
        _profile = updatedProfile;
      });
      widget.onProfileUpdated(updatedProfile);
    }

    await _loadPremiumTitle();
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  String _roleLabel(String? role) {
    switch ((role ?? '').toUpperCase()) {
      case 'PATIENT':
        return 'Bệnh nhân';
      case 'DOCTOR':
        return 'Bác sĩ';
      case 'ADMIN':
        return 'Quản trị viên';
      default:
        return 'Người dùng';
    }
  }

  String _initials(String name) {
    final List<String> parts = name
        .split(RegExp(r'\s+'))
        .where((String part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'GC';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Widget _buildProfileAvatar({
    required String fullName,
    String? avatarUrl,
    double radius = 33,
  }) {
    final double diameter = radius * 2;
    final String imageUrl = (avatarUrl ?? '').trim();

    Widget fallbackAvatar() {
      return Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: Color(0xFFDFF5FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _initials(fullName),
          style: TextStyle(
            color: const Color(0xFF0E4777),
            fontSize: radius * 0.72,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return SizedBox(
      width: diameter,
      height: diameter,
      child: imageUrl.isEmpty
          ? fallbackAvatar()
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallbackAvatar(),
              ),
            ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color iconBackground = const Color(0xFFDCEFFC),
    Color iconColor = const Color(0xFF1E5C92),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF18354F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((subtitle ?? '').trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFF658196),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6E8799),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = (_profile?.fullName ?? '').trim().isEmpty
        ? 'Người dùng GluCare'
        : _profile!.fullName.trim();
    final String phoneNumber = (_profile?.phoneNumber ?? '').trim();
    final String email = (_profile?.email ?? '').trim();
    final String roleLabel = _roleLabel(_profile?.role);
    final _PremiumProfileTitleData? premiumTitle = _premiumTitle;

    return Container(
      color: const Color(0xFFDDF2FB),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tài khoản',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1564A6), Color(0xFF07173A)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: _isLoadingProfile
                    ? const SizedBox(
                        height: 112,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildProfileAvatar(
                                fullName: fullName,
                                avatarUrl: _profile?.avatarUrl,
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isUploadingAvatar
                                        ? null
                                        : () {
                                            unawaited(_pickAndUploadAvatar());
                                          },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFB8D9EF),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _isUploadingAvatar
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.camera_alt_rounded,
                                              size: 15,
                                              color: Color(0xFF0E4777),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  roleLabel,
                                  style: const TextStyle(
                                    color: Color(0xFFD0E9FA),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (premiumTitle != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x26FFE38A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0x66FFE38A),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 1),
                                          child: Icon(
                                            Icons.workspace_premium_rounded,
                                            color: Color(0xFFFFF4C2),
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Danh hiệu: ${premiumTitle.label}',
                                                style: const TextStyle(
                                                  color: Color(0xFFFFF4C2),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                premiumTitle.validityText,
                                                style: const TextStyle(
                                                  color: Color(0xFFFFF4C2),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else
                                  const SizedBox(height: 6),
                                const Text(
                                  'Chạm biểu tượng máy ảnh để thay ảnh đại diện',
                                  style: TextStyle(
                                    color: Color(0xFFDFF3FF),
                                    fontSize: 12,
                                  ),
                                ),
                                if (phoneNumber.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    phoneNumber,
                                    style: const TextStyle(
                                      color: Color(0xFFDFF3FF),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Color(0xFFDFF3FF),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              if ((_profileMessage ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isProfileMessageError
                        ? const Color(0xFFFFE7E7)
                        : const Color(0xFFE8F7E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isProfileMessageError
                          ? const Color(0xFFFFB7B7)
                          : const Color(0xFF97D8A1),
                    ),
                  ),
                  child: Text(
                    _profileMessage!,
                    style: TextStyle(
                      color: _isProfileMessageError
                          ? const Color(0xFFB3261E)
                          : const Color(0xFF166534),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _buildSectionCard(
                children: [
                  _buildMenuTile(
                    icon: Icons.badge_outlined,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Cập nhật hồ sơ tài khoản từ máy chủ',
                    onTap: () {
                      unawaited(_openEditProfilePage());
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE2EDF3)),
                  _buildMenuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Thanh toán gói Premium',
                    subtitle:
                        'Mở thanh toán trong app, xem lịch sử giao dịch và trạng thái kích hoạt',
                    onTap: () {
                      unawaited(_openPaymentPage());
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE2EDF3)),
                  _buildMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Bảo mật tài khoản',
                    subtitle: 'Quản lý đăng nhập và quyền riêng tư',
                    onTap: () {
                      unawaited(
                        _showInfoDialog(
                          title: 'Bảo mật tài khoản',
                          message:
                              'API hiện đã hỗ trợ cập nhật hồ sơ qua /v1/profile. Nếu cần đặt lại mật khẩu, hãy dùng mục Quên mật khẩu ở màn hình đăng nhập.',
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                children: [
                  _buildMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Thông báo',
                    subtitle: 'Nhận nhắc nhở và cập nhật quan trọng',
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        unawaited(_setNotificationsEnabled(value));
                      },
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2EDF3)),
                  _buildMenuTile(
                    icon: Icons.alarm_rounded,
                    title: 'Nhắc lịch theo dõi',
                    subtitle: 'Bật nhắc đo đường huyết và uống thuốc',
                    trailing: Switch.adaptive(
                      value: _remindersEnabled,
                      onChanged: (bool value) {
                        unawaited(_setRemindersEnabled(value));
                      },
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2EDF3)),
                  _buildMenuTile(
                    icon: Icons.settings_suggest_outlined,
                    title: 'Cài đặt ứng dụng',
                    subtitle: 'Mở cài đặt hệ thống cho ứng dụng này',
                    onTap: () {
                      unawaited(_openPhoneSettings());
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE2EDF3)),
                  _buildMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Trợ giúp',
                    subtitle: 'Hướng dẫn sử dụng và hỗ trợ',
                    onTap: () {
                      unawaited(
                        _showInfoDialog(
                          title: 'Trợ giúp',
                          message:
                              'Nếu có vấn đề với dữ liệu hoặc tài khoản, bạn có thể đăng xuất và đăng nhập lại hoặc liên hệ nhóm hỗ trợ của dự án.',
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _confirmLogout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    _isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12355A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

class _PremiumProfileTitleData {
  const _PremiumProfileTitleData({
    required this.label,
    required this.validityText,
  });

  final String label;
  final String validityText;
}

DateTime? _resolvePremiumExpiry(PaymentHistoryItemData item) {
  final String normalizedPackageType =
      PaymentHistoryItemData.normalizePackageType(item.packageType);

  if (normalizedPackageType == 'L') {
    return null;
  }

  if (item.expiresAt != null) {
    return item.expiresAt;
  }

  final DateTime? purchaseTime = item.paidAt ?? item.createdAt;
  if (purchaseTime == null) {
    return null;
  }

  switch (normalizedPackageType) {
    case 'M':
      return DateTime(
        purchaseTime.year,
        purchaseTime.month + 1,
        purchaseTime.day,
        purchaseTime.hour,
        purchaseTime.minute,
        purchaseTime.second,
        purchaseTime.millisecond,
        purchaseTime.microsecond,
      );
    case 'Y':
      return DateTime(
        purchaseTime.year + 1,
        purchaseTime.month,
        purchaseTime.day,
        purchaseTime.hour,
        purchaseTime.minute,
        purchaseTime.second,
        purchaseTime.millisecond,
        purchaseTime.microsecond,
      );
    default:
      return null;
  }
}

bool _isPremiumPaymentActive(PaymentHistoryItemData item) {
  final String status = item.status.toUpperCase();
  final String normalizedPackageType =
      PaymentHistoryItemData.normalizePackageType(item.packageType);
  if (status != 'SUCCESS' && status != 'ACTIVE') {
    return false;
  }

  if (item.isActive) {
    return true;
  }

  if (normalizedPackageType == 'L') {
    return true;
  }

  final DateTime? expiry = _resolvePremiumExpiry(item);
  return expiry != null && expiry.isAfter(DateTime.now());
}

PaymentHistoryItemData? _findActivePremiumPayment(
  List<PaymentHistoryItemData> history,
) {
  for (final PaymentHistoryItemData item in history) {
    if (_isPremiumPaymentActive(item)) {
      return item;
    }
  }
  return null;
}

PaymentHistoryItemData? _findLatestSuccessfulPremiumPayment(
  List<PaymentHistoryItemData> history,
) {
  for (final PaymentHistoryItemData item in history) {
    final String status = item.status.toUpperCase();
    if (status == 'SUCCESS' || status == 'ACTIVE') {
      return item;
    }
  }
  return null;
}

String _formatPremiumValidityDate(DateTime value) {
  final DateTime local = value.toLocal();
  final String day = local.day.toString().padLeft(2, '0');
  final String month = local.month.toString().padLeft(2, '0');
  final String year = local.year.toString();
  return '$day/$month/$year';
}

_PremiumProfileTitleData? _derivePremiumProfileTitle(
  List<PaymentHistoryItemData> history,
) {
  final PaymentHistoryItemData? paymentForTitle =
      _findActivePremiumPayment(history) ??
      _findLatestSuccessfulPremiumPayment(history);
  if (paymentForTitle == null) {
    return null;
  }

  final String normalizedPackageType =
      PaymentHistoryItemData.normalizePackageType(paymentForTitle.packageType);

  switch (normalizedPackageType) {
    case 'M':
      final DateTime? expiry = _resolvePremiumExpiry(paymentForTitle);
      if (expiry == null || !expiry.isAfter(DateTime.now())) {
        return const _PremiumProfileTitleData(
          label: 'Premium',
          validityText: 'Tài khoản Premium đang hoạt động',
        );
      }
      return _PremiumProfileTitleData(
        label: 'Premium Tháng',
        validityText: 'Hiệu lực đến ${_formatPremiumValidityDate(expiry)}',
      );
    case 'Y':
      final DateTime? expiry = _resolvePremiumExpiry(paymentForTitle);
      if (expiry == null || !expiry.isAfter(DateTime.now())) {
        return const _PremiumProfileTitleData(
          label: 'Premium',
          validityText: 'Tài khoản Premium đang hoạt động',
        );
      }
      return _PremiumProfileTitleData(
        label: 'Premium Năm',
        validityText: 'Hiệu lực đến ${_formatPremiumValidityDate(expiry)}',
      );
    case 'L':
      return const _PremiumProfileTitleData(
        label: 'Premium Trọn Đời',
        validityText: 'Danh hiệu trọn đời đang hoạt động',
      );
    default:
      final DateTime? expiry = _resolvePremiumExpiry(paymentForTitle);
      return _PremiumProfileTitleData(
        label: 'Premium',
        validityText: expiry != null && expiry.isAfter(DateTime.now())
            ? 'Hiệu lực đến ${_formatPremiumValidityDate(expiry)}'
            : 'Tài khoản Premium đang hoạt động',
      );
  }
}

class _SafeAssetImage extends StatelessWidget {
  const _SafeAssetImage({
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.mutedBlue,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _EditAccountProfilePage extends StatefulWidget {
  const _EditAccountProfilePage({required this.initialProfile});

  final UserProfileData initialProfile;

  @override
  State<_EditAccountProfilePage> createState() =>
      _EditAccountProfilePageState();
}

class _EditAccountProfilePageState extends State<_EditAccountProfilePage> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  late final TextEditingController _nameController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _specializationController;
  late UserProfileData _workingProfile;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _showValidationErrors = false;
  String? _submitErrorMessage;
  String? _successMessage;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  String? get _nameError {
    if (!_showValidationErrors) {
      return null;
    }

    final String fullName = _nameController.text.trim();
    if (fullName.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (fullName.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? get _dateOfBirthError {
    if (!_showValidationErrors) {
      return null;
    }

    final bool isPatient = widget.initialProfile.role.toUpperCase().contains(
      'PATIENT',
    );
    if (isPatient && _selectedDateOfBirth == null) {
      return 'Vui lòng chọn ngày sinh';
    }
    return null;
  }

  bool get _isDoctorRole {
    return widget.initialProfile.role.toUpperCase().contains('DOCTOR');
  }

  bool get _isPatientRole {
    return widget.initialProfile.role.toUpperCase().contains('PATIENT');
  }

  @override
  void initState() {
    super.initState();
    _workingProfile = widget.initialProfile;
    _nameController = TextEditingController(text: _workingProfile.fullName);
    _hospitalController = TextEditingController(
      text: _workingProfile.hospital ?? '',
    );
    _specializationController = TextEditingController(
      text: _workingProfile.specialization ?? '',
    );
    _selectedGender = (_workingProfile.gender ?? '').trim().isEmpty
        ? null
        : _workingProfile.gender;
    final String rawDate = (_workingProfile.dateOfBirth ?? '').trim();
    if (rawDate.isNotEmpty) {
      _selectedDateOfBirth = DateTime.tryParse(rawDate);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String year = value.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDateOfBirth = picked;
      _submitErrorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar || _isSaving) {
      return;
    }

    final File? avatarFile = await _pickAvatarFileWithCrop(context);
    if (avatarFile == null) {
      return;
    }

    setState(() {
      _isUploadingAvatar = true;
      _submitErrorMessage = null;
      _successMessage = null;
    });

    try {
      final UserProfileData? updatedProfile = await _backendApiService
          .uploadProfileAvatar(avatarFile);
      if (!mounted) {
        return;
      }

      setState(() {
        _workingProfile = updatedProfile ?? _workingProfile;
        _successMessage = 'Ảnh đại diện đã được cập nhật.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitErrorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  String _initials(String name) {
    final List<String> parts = name
        .split(RegExp(r'\s+'))
        .where((String part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'GC';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Widget _buildAvatarPreview({double radius = 42}) {
    final double diameter = radius * 2;
    final String fullName = _nameController.text.trim().isEmpty
        ? _workingProfile.fullName
        : _nameController.text.trim();
    final String imageUrl = (_workingProfile.avatarUrl ?? '').trim();

    Widget fallbackAvatar() {
      return Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: Color(0xFFDFF5FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _initials(fullName),
          style: TextStyle(
            color: const Color(0xFF0E4777),
            fontSize: radius * 0.72,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return SizedBox(
      width: diameter,
      height: diameter,
      child: imageUrl.isEmpty
          ? fallbackAvatar()
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallbackAvatar(),
              ),
            ),
    );
  }

  Future<void> _saveProfile() async {
    final String fullName = _nameController.text.trim();
    setState(() {
      _showValidationErrors = true;
      _submitErrorMessage = null;
      _successMessage = null;
    });

    if (_nameError != null || _dateOfBirthError != null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (!mounted) {
      return;
    }

    try {
      final UserProfileData? updatedProfile = await _backendApiService
          .updateCurrentUserProfile(
            fullName: fullName,
            gender: _selectedGender,
            dateOfBirth: _selectedDateOfBirth?.toIso8601String(),
            specialization: _specializationController.text.trim(),
            hospital: _hospitalController.text.trim(),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        updatedProfile ??
            _workingProfile.copyWith(
              fullName: fullName,
              gender: _selectedGender,
              dateOfBirth: _selectedDateOfBirth?.toIso8601String(),
              specialization: _specializationController.text.trim().isEmpty
                  ? null
                  : _specializationController.text.trim(),
              hospital: _hospitalController.text.trim().isEmpty
                  ? null
                  : _hospitalController.text.trim(),
            ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitErrorMessage = error.toString().replaceFirst('Exception: ', '');
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1564A6),
        foregroundColor: Colors.white,
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Các thay đổi tại đây sẽ được gửi lên hồ sơ tài khoản qua API mới. Sau khi lưu, Trang chủ và mục Tài khoản sẽ dùng lại dữ liệu máy chủ.',
                  style: TextStyle(
                    color: Color(0xFF305167),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if ((_submitErrorMessage ?? '').trim().isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFB7B7)),
                  ),
                  child: Text(
                    _submitErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if ((_successMessage ?? '').trim().isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF97D8A1)),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildAvatarPreview(),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isUploadingAvatar
                                  ? null
                                  : () {
                                      unawaited(_pickAndUploadAvatar());
                                    },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1564A6),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white),
                                ),
                                alignment: Alignment.center,
                                child: _isUploadingAvatar
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ảnh đại diện',
                      style: TextStyle(
                        color: Color(0xFF17324F),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chọn ảnh từ thư viện để cập nhật hồ sơ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF658196),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isUploadingAvatar
                          ? null
                          : () {
                              unawaited(_pickAndUploadAvatar());
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        _isUploadingAvatar
                            ? 'Đang tải ảnh...'
                            : 'Đổi ảnh đại diện',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Họ và tên',
                style: TextStyle(
                  color: Color(0xFF17324F),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                onChanged: (_) {
                  if (_showValidationErrors || _successMessage != null) {
                    setState(() {
                      _successMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Nhập tên hiển thị',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_nameError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _nameError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (_isPatientRole) ...[
                const Text(
                  'Giới tính',
                  style: TextStyle(
                    color: Color(0xFF17324F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                      _submitErrorMessage = null;
                      _successMessage = null;
                    });
                  },
                  items: const [
                    DropdownMenuItem<String>(value: 'M', child: Text('Nam')),
                    DropdownMenuItem<String>(value: 'F', child: Text('Nữ')),
                    DropdownMenuItem<String>(value: 'O', child: Text('Khác')),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ngày sinh',
                  style: TextStyle(
                    color: Color(0xFF17324F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _selectedDateOfBirth == null
                          ? 'Chọn ngày sinh'
                          : _formatDate(_selectedDateOfBirth!),
                      style: TextStyle(
                        color: _selectedDateOfBirth == null
                            ? const Color(0xFF6B8496)
                            : const Color(0xFF17324F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_dateOfBirthError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _dateOfBirthError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if (_isDoctorRole) ...[
                const Text(
                  'Chuyên khoa',
                  style: TextStyle(
                    color: Color(0xFF17324F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _specializationController,
                  onChanged: (_) {
                    if (_submitErrorMessage != null ||
                        _successMessage != null) {
                      setState(() {
                        _submitErrorMessage = null;
                        _successMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ví dụ: Nội tiết',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bệnh viện',
                  style: TextStyle(
                    color: Color(0xFF17324F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _hospitalController,
                  onChanged: (_) {
                    if (_submitErrorMessage != null ||
                        _successMessage != null) {
                      setState(() {
                        _submitErrorMessage = null;
                        _successMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Tên cơ sở y tế',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Số điện thoại',
                style: TextStyle(
                  color: Color(0xFF17324F),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.initialProfile.phoneNumber.trim().isEmpty
                      ? 'Chưa cập nhật'
                      : widget.initialProfile.phoneNumber,
                  style: const TextStyle(
                    color: Color(0xFF4A6679),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if ((widget.initialProfile.email ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF17324F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    widget.initialProfile.email!,
                    style: const TextStyle(
                      color: Color(0xFF4A6679),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12355A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(fontWeight: FontWeight.w700),
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

class _PaymentPlanInfo {
  const _PaymentPlanInfo({
    required this.packageType,
    required this.title,
    required this.subtitle,
    required this.priceVnd,
    required this.badge,
  });

  final String packageType;
  final String title;
  final String subtitle;
  final int priceVnd;
  final String badge;
}

class _PaymentSettingsPage extends StatefulWidget {
  const _PaymentSettingsPage({required this.profile});

  final UserProfileData profile;

  @override
  State<_PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends State<_PaymentSettingsPage> {
  static const List<_PaymentPlanInfo> _plans = <_PaymentPlanInfo>[
    _PaymentPlanInfo(
      packageType: 'M',
      title: 'Gói tháng',
      subtitle: 'Sử dụng trong 1 tháng',
      priceVnd: 50000,
      badge: 'Phổ biến',
    ),
    _PaymentPlanInfo(
      packageType: 'Y',
      title: 'Gói năm',
      subtitle: 'Tiết kiệm cho 12 tháng',
      priceVnd: 450000,
      badge: 'Tiết kiệm',
    ),
    _PaymentPlanInfo(
      packageType: 'L',
      title: 'Gói trọn đời',
      subtitle: 'Kích hoạt vĩnh viễn',
      priceVnd: 1000000,
      badge: 'Forever',
    ),
  ];

  final BackendApiService _backendApiService = BackendApiService.instance;

  late UserProfileData _profile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _noticeMessage;
  String? _cancellingTransactionId;
  String? _initiatingPackageType;
  List<PaymentHistoryItemData> _paymentHistory =
      const <PaymentHistoryItemData>[];

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    unawaited(_loadPaymentHistory());
  }

  PaymentHistoryItemData? get _activePayment {
    final DateTime now = DateTime.now();
    for (final PaymentHistoryItemData item in _paymentHistory) {
      final String normalizedPackageType =
          PaymentHistoryItemData.normalizePackageType(item.packageType);
      final bool lifetimeActive =
          normalizedPackageType == 'L' && item.status == 'SUCCESS';
      final bool expiryActive =
          item.expiresAt != null && item.expiresAt!.isAfter(now);
      if (item.isActive || lifetimeActive || expiryActive) {
        return item;
      }
    }

    for (final PaymentHistoryItemData item in _paymentHistory) {
      if (item.status == 'SUCCESS') {
        return item;
      }
    }
    return null;
  }

  String _planLabel(String packageType) {
    final String normalizedPackageType =
        PaymentHistoryItemData.normalizePackageType(packageType);
    final _PaymentPlanInfo? plan = _plans
        .where(
          (_PaymentPlanInfo item) => item.packageType == normalizedPackageType,
        )
        .firstOrNull;
    return plan?.title ??
        (packageType.trim().isEmpty ? 'Premium' : packageType);
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'Thành công';
      case 'PENDING':
        return 'Đang chờ';
      case 'FAILED':
        return 'Thất bại';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'ACTIVE':
        return 'Đang hoạt động';
      default:
        return status.isEmpty ? 'Không rõ' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'ACTIVE':
        return const Color(0xFF166534);
      case 'PENDING':
        return const Color(0xFF9A6700);
      case 'FAILED':
      case 'CANCELLED':
        return const Color(0xFFB3261E);
      default:
        return const Color(0xFF305167);
    }
  }

  Color _statusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'ACTIVE':
        return const Color(0xFFE8F7E9);
      case 'PENDING':
        return const Color(0xFFFFF4D6);
      case 'FAILED':
      case 'CANCELLED':
        return const Color(0xFFFFE7E7);
      default:
        return const Color(0xFFEAF3F8);
    }
  }

  String _formatCurrency(double? amount, {int? fallback}) {
    final int value = (amount ?? fallback ?? 0).round();
    final String digits = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < digits.length; index++) {
      final int reverseIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} VND';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Chưa có';
    }
    final DateTime local = value.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String year = local.year.toString();
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  bool _shouldDisplayHistoryItem(PaymentHistoryItemData item) {
    final String status = item.status.toUpperCase();
    return status == 'PENDING' || status == 'SUCCESS';
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<PaymentHistoryItemData> history = await _backendApiService
          .fetchPaymentHistory(page: 1, limit: 20);
      if (!mounted) {
        return;
      }
      setState(() {
        _paymentHistory = history
            .where(_shouldDisplayHistoryItem)
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startPayment(_PaymentPlanInfo plan) async {
    final String userId = _profile.id.trim();
    if (userId.isEmpty) {
      setState(() {
        _errorMessage = 'Không tìm thấy userId để khởi tạo thanh toán.';
      });
      return;
    }

    setState(() {
      _initiatingPackageType = plan.packageType;
      _errorMessage = null;
      _noticeMessage = null;
    });

    try {
      final PaymentInitiationData initiation = await _backendApiService
          .initiatePayment(userId: userId, packageType: plan.packageType);
      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _PaymentWebViewPage(
            paymentUrl: initiation.paymentUrl,
            title: plan.title,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _noticeMessage =
            'Đã quay lại từ trang thanh toán. Đang làm mới trạng thái giao dịch.';
      });
      await _loadPaymentHistory();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _initiatingPackageType = null;
        });
      }
    }
  }

  Future<void> _cancelPendingPayment(PaymentHistoryItemData item) async {
    if (_cancellingTransactionId != null) {
      return;
    }

    final bool shouldCancel =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hủy giao dịch chờ'),
              content: Text(
                'Bạn có chắc muốn hủy giao dịch ${item.id.isEmpty ? '' : item.id} không?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Giữ lại'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Hủy giao dịch'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldCancel) {
      return;
    }

    setState(() {
      _cancellingTransactionId = item.id.trim().isEmpty
          ? '__latest__'
          : item.id;
      _errorMessage = null;
      _noticeMessage = null;
    });

    try {
      await _backendApiService.cancelPendingPayment(transactionId: item.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _noticeMessage = 'Đã gửi yêu cầu hủy giao dịch chờ.';
      });
      await _loadPaymentHistory();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _cancellingTransactionId = null;
        });
      }
    }
  }

  Widget _buildMessageBox({required String text, required bool isError}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFE7E7) : const Color(0xFFE8F7E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? const Color(0xFFFFB7B7) : const Color(0xFF97D8A1),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isError ? const Color(0xFFB3261E) : const Color(0xFF166534),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlanCard(_PaymentPlanInfo plan) {
    final bool isBusy = _initiatingPackageType == plan.packageType;
    final PaymentHistoryItemData? active = _activePayment;
    final bool isCurrentPlan = active?.packageType == plan.packageType;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF1564A6)
              : const Color(0xFFDCE8F0),
          width: isCurrentPlan ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEFFC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plan.badge,
                  style: const TextStyle(
                    color: Color(0xFF1564A6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (isCurrentPlan)
                const Text(
                  'Đang dùng',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            plan.title,
            style: const TextStyle(
              color: Color(0xFF17324F),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            plan.subtitle,
            style: const TextStyle(
              color: Color(0xFF658196),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _formatCurrency(null, fallback: plan.priceVnd),
            style: const TextStyle(
              color: Color(0xFF07173A),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isBusy ? null : () => _startPayment(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12355A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Thanh toán trong app',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PaymentHistoryItemData item) {
    final Color statusColor = _statusColor(item.status);
    final bool isPending = item.status.toUpperCase() == 'PENDING';
    final bool isCancelling =
        _cancellingTransactionId != null &&
        _cancellingTransactionId ==
            (item.id.trim().isEmpty ? '__latest__' : item.id);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _planLabel(item.packageType),
                  style: const TextStyle(
                    color: Color(0xFF17324F),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusBackgroundColor(item.status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(item.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(item.amount),
            style: const TextStyle(
              color: Color(0xFF07173A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Khởi tạo: ${_formatDateTime(item.createdAt)}',
            style: const TextStyle(color: Color(0xFF5E7688), fontSize: 13),
          ),
          if (item.paidAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Thanh toán: ${_formatDateTime(item.paidAt)}',
              style: const TextStyle(color: Color(0xFF5E7688), fontSize: 13),
            ),
          ],
          if (item.expiresAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Hiệu lực đến: ${_formatDateTime(item.expiresAt)}',
              style: const TextStyle(color: Color(0xFF5E7688), fontSize: 13),
            ),
          ],
          if (item.id.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Mã giao dịch: ${item.id}',
              style: const TextStyle(color: Color(0xFF5E7688), fontSize: 13),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCancelling
                    ? null
                    : () {
                        unawaited(_cancelPendingPayment(item));
                      },
                icon: isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close_rounded),
                label: Text(
                  isCancelling ? 'Đang hủy giao dịch...' : 'Hủy giao dịch chờ',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB3261E),
                  side: const BorderSide(color: Color(0xFFFFB7B7)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaymentHistoryItemData? activePayment = _activePayment;
    final String activeTitle = activePayment == null
        ? 'Chưa có gói Premium đang hoạt động'
        : 'Gói hiện tại: ${_planLabel(activePayment.packageType)}';
    final String activeSubtitle = activePayment == null
        ? 'Bạn có thể chọn gói tháng, năm hoặc trọn đời và thanh toán ngay trong app.'
        : PaymentHistoryItemData.normalizePackageType(
                activePayment.packageType,
              ) ==
              'L'
        ? 'Gói trọn đời đang hoạt động trên tài khoản này.'
        : activePayment.expiresAt != null
        ? 'Hiệu lực đến ${_formatDateTime(activePayment.expiresAt)}.'
        : 'Giao dịch gần nhất đang được xem là có hiệu lực.';

    return Scaffold(
      backgroundColor: const Color(0xFFDDF2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1564A6),
        foregroundColor: Colors.white,
        title: const Text('Thanh toán Premium'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPaymentHistory,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1564A6), Color(0xFF07173A)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeSubtitle,
                      style: const TextStyle(
                        color: Color(0xFFDFF3FF),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if ((_errorMessage ?? '').trim().isNotEmpty) ...[
                _buildMessageBox(text: _errorMessage!, isError: true),
                const SizedBox(height: 14),
              ],
              if ((_noticeMessage ?? '').trim().isNotEmpty) ...[
                _buildMessageBox(text: _noticeMessage!, isError: false),
                const SizedBox(height: 14),
              ],
              const Text(
                'Chọn gói thanh toán',
                style: TextStyle(
                  color: Color(0xFF17324F),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              for (final _PaymentPlanInfo plan in _plans) _buildPlanCard(plan),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Lịch sử thanh toán',
                      style: TextStyle(
                        color: Color(0xFF17324F),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading
                        ? null
                        : () => unawaited(_loadPaymentHistory()),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_paymentHistory.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Chưa có giao dịch nào. Hãy chọn một gói để bắt đầu.',
                    style: TextStyle(
                      color: Color(0xFF5E7688),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                )
              else
                for (final PaymentHistoryItemData item in _paymentHistory)
                  _buildHistoryCard(item),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentWebViewPage extends StatefulWidget {
  const _PaymentWebViewPage({required this.paymentUrl, required this.title});

  final String paymentUrl;
  final String title;

  @override
  State<_PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<_PaymentWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progress = progress;
            });
          },
          onPageStarted: (String url) {
            if (!mounted) {
              return;
            }
            setState(() {
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) {
              return;
            }
            setState(() {
              _currentUrl = url;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1564A6),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress >= 100
              ? const SizedBox.shrink()
              : LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 2,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFEAF3F8),
            child: Text(
              (_currentUrl ?? widget.paymentUrl).trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF4A6679), fontSize: 12),
            ),
          ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
