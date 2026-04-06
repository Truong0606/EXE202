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
import 'package:image_picker/image_picker.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

part 'home_page_extras.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  final AccountSettingsService _accountSettingsService =
      AccountSettingsService.instance;

  late int currentTabIndex;
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
    UserProfileData? userProfile = await _backendApiService
        .fetchCurrentUserProfile();
    if (!mounted || userProfile == null) {
      return;
    }

    userProfile = await _accountSettingsService.applyProfileOverrides(userProfile);
    if (!mounted) {
      return;
    }

    final String fullName = userProfile.fullName.trim();
    if (fullName.isEmpty) {
      return;
    }

    setState(() {
      _currentUserProfile = userProfile;
      _displayName = fullName;
    });
  }

  void _handleProfileUpdated(UserProfileData profile) {
    setState(() {
      _currentUserProfile = profile;
      if (profile.fullName.trim().isNotEmpty) {
        _displayName = profile.fullName.trim();
      }
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
      blogArticleErrorMessage = error.toString().replaceFirst('Exception: ', '');
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
        ..addAll(records.map((GlucoseHistoryItemData item) => item.glucoseValue));
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
                              path: 'assets/images/homepage/Mascot Head 2 3.png',
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
    final Color glowColor = Color.lerp(
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
        final double glowAlpha = 0.18 + (normalizedScore * 0.18) + (pulse * 0.12);
        final double blurRadius = 8 + (normalizedScore * 8) + (pulse * 8);
        final double spreadRadius = 0.5 + (normalizedScore * 1.5) + (pulse * 1.5);
        final double heartFill = 0.2 + (normalizedScore * 0.45) + (pulse * 0.25);

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
                  color: glowColor.withValues(alpha: glowAlpha.clamp(0.0, 0.55)),
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
                color: Color.lerp(
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
  const _AccountTab({this.profile, required this.onProfileUpdated});

  final UserProfileData? profile;
  final ValueChanged<UserProfileData> onProfileUpdated;

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  final AccountSettingsService _accountSettingsService =
      AccountSettingsService.instance;

  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
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
    }
  }

  Future<void> _loadSettingsState() async {
    final bool notificationsEnabled =
        await _accountSettingsService.getNotificationsEnabled();
    final bool remindersEnabled =
        await _accountSettingsService.getRemindersEnabled();
    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _remindersEnabled = remindersEnabled;
      _profile = widget.profile;
      _isLoadingProfile = false;
    });
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

    final bool shouldLogout = await showDialog<bool>(
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

  Future<void> _openEditProfilePage() async {
    final UserProfileData seedProfile = _profile ??
        const UserProfileData(
          id: '',
          phoneNumber: '',
          role: 'PATIENT',
          fullName: '',
        );

    final UserProfileData? updatedProfile = await Navigator.of(context).push<
        UserProfileData>(
      MaterialPageRoute<UserProfileData>(
        builder: (_) => _EditAccountProfilePage(initialProfile: seedProfile),
      ),
    );
    if (!mounted || updatedProfile == null) {
      return;
    }

    await _accountSettingsService.saveProfileOverrides(
      fullName: updatedProfile.fullName,
      email: updatedProfile.email,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = updatedProfile;
    });
    widget.onProfileUpdated(updatedProfile);
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
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
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
                          CircleAvatar(
                            radius: 33,
                            backgroundColor: const Color(0xFFDFF5FF),
                            child: Text(
                              _initials(fullName),
                              style: const TextStyle(
                                color: Color(0xFF0E4777),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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
              const SizedBox(height: 18),
              _buildSectionCard(
                children: [
                  _buildMenuTile(
                    icon: Icons.badge_outlined,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Chỉnh sửa tên hiển thị và email trên thiết bị',
                    onTap: () {
                      unawaited(_openEditProfilePage());
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
                              'Đã kiểm tra API hiện có: app đọc profile qua /v1/auth/me, nhưng chưa có endpoint cập nhật hồ sơ hoặc đổi mật khẩu được tài liệu hóa cho màn hình này. Vì vậy phần chỉnh sửa hồ sơ hiện được lưu cục bộ trên thiết bị.',
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
  State<_EditAccountProfilePage> createState() => _EditAccountProfilePageState();
}

class _EditAccountProfilePageState extends State<_EditAccountProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.fullName);
    _emailController = TextEditingController(
      text: widget.initialProfile.email ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final String fullName = _nameController.text.trim();
    final String email = _emailController.text.trim();
    if (fullName.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      widget.initialProfile.copyWith(
        fullName: fullName,
        email: email.isEmpty ? null : email,
      ),
    );
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
                  'Đã kiểm tra API: hiện có thể đọc hồ sơ qua /v1/auth/me nhưng chưa có endpoint cập nhật hồ sơ cho màn hình này. Các thay đổi bên dưới sẽ được lưu cục bộ trên thiết bị và áp dụng cho Trang chủ cùng mục Tài khoản.',
                  style: TextStyle(
                    color: Color(0xFF305167),
                    fontSize: 13,
                    height: 1.45,
                  ),
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
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'you@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
