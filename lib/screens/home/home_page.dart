import 'dart:async';
import 'dart:math' as math;

import 'package:first_app/core/services/notification_service.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'home_page_extras.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int currentTabIndex;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialTabIndex.clamp(0, 4);
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
              onOpenAiTab: () {
                setState(() {
                  currentTabIndex = 2;
                });
              },
            ),
            const _DiaryTab(),
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
            ),
            const _PlaceholderTab(title: 'Tài khoản'),
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
  const _DashboardTab({required this.onOpenAiTab});

  final VoidCallback onOpenAiTab;

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  static const int _glucoseGoalPercent = 50;
  static const int _weeklyGoalPercent = 40;

  DateTime displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedDate = DateTime.now();
  final List<double> _glucose24hPoints = <double>[];
  final math.Random _random = math.Random();
  Timer? _liveDataTimer;
  double _lastMockValue = 136;

  @override
  void initState() {
    super.initState();
    _startRealtimeGlucoseUpdates();
    unawaited(
      NotificationService.instance.notifyWeeklyGoalReachedIfNeeded(
        glucoseGoalPercent: _glucoseGoalPercent,
        weeklyGoalPercent: _weeklyGoalPercent,
      ),
    );
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    super.dispose();
  }

  void _startRealtimeGlucoseUpdates() {
    _liveDataTimer?.cancel();
    _liveDataTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _addRealtimeGlucosePoint();
    });
  }

  void _addRealtimeGlucosePoint() {
    final double previous =
        _glucose24hPoints.isNotEmpty ? _glucose24hPoints.last : _lastMockValue;
    final double delta = (_random.nextDouble() * 14) - 7;
    final double nextValue = (previous + delta).clamp(72, 220);

    if (!mounted) {
      return;
    }

    setState(() {
      _glucose24hPoints.add(nextValue);
      if (_glucose24hPoints.length > 24) {
        _glucose24hPoints.removeAt(0);
      }
      _lastMockValue = nextValue;
    });
  }

  List<int?> _buildCalendarCells(DateTime month) {
    final DateTime firstDay = DateTime(month.year, month.month, 1);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final int leadingEmpty = (firstDay.weekday + 6) % 7;
    final List<int?> cells = List<int?>.filled(leadingEmpty, null, growable: true);
    cells.addAll(List<int?>.generate(daysInMonth, (index) => index + 1));

    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  void _goToPreviousMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
      final int day = selectedDate.day;
      final int maxDay =
          DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
      selectedDate = DateTime(
        displayedMonth.year,
        displayedMonth.month,
        day > maxDay ? maxDay : day,
      );
    });
  }

  void _goToNextMonth() {
    final DateTime now = DateTime.now();
    final DateTime latestAllowed = DateTime(now.year, now.month);
    final DateTime nextMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1);
    if (nextMonth.isAfter(latestAllowed)) {
      return;
    }

    setState(() {
      displayedMonth = nextMonth;
      final int day = selectedDate.day;
      final int maxDay =
          DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
      selectedDate = DateTime(
        displayedMonth.year,
        displayedMonth.month,
        day > maxDay ? maxDay : day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime latestAllowedMonth = DateTime(now.year, now.month);
    final bool canGoNext = !DateTime(
      displayedMonth.year,
      displayedMonth.month,
    ).isAtSameMomentAs(latestAllowedMonth);
    final int latestGlucose = _lastMockValue.round();
    final List<int?> calendarCells = _buildCalendarCells(displayedMonth);
    const List<String> weekdays = ['Th.2', 'Th.3', 'Th.4', 'Th.5', 'Th.6', 'Th.7', 'CN'];

    return SingleChildScrollView(
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
                    const Expanded(
                      child: Text(
                        'Xin chào,\nGluCare',
                        style: TextStyle(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                      '$latestGlucose',
                                      style: TextStyle(
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
                              const Text(
                                'Trước khi ăn\nVào lúc 06:50 AM',
                                style: TextStyle(
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
                                      text: '$_glucoseGoalPercent',
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
                              Text(
                                'Mục tiêu tuần này:  $_weeklyGoalPercent%',
                                style: const TextStyle(
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
                                  child: CustomPaint(
                                    painter: _GoalProgressRingPainter(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          builder: (_) => const QuickEntryPage(),
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
                            path: 'assets/images/homepage/basil_camera-solid.png',
                            width: 12,
                            height: 12,
                          ),
                        ),
                        const SizedBox(width: 0),
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
                  'Theo dõi mục tiêu tháng 11',
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
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _goToPreviousMonth,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF16395B),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Tháng ${displayedMonth.month}/${displayedMonth.year}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF16395B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: canGoNext ? _goToNextMonth : null,
                            icon: Icon(
                              Icons.chevron_right,
                              color: canGoNext
                                  ? const Color(0xFF16395B)
                                  : const Color(0x6616395B),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          for (final label in weekdays)
                            Expanded(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF16395B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: calendarCells.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1.45,
                        ),
                        itemBuilder: (context, index) {
                          final int? day = calendarCells[index];
                          final bool selected =
                              day != null &&
                              selectedDate.year == displayedMonth.year &&
                              selectedDate.month == displayedMonth.month &&
                              selectedDate.day == day;

                          if (day == null) {
                            return const SizedBox.shrink();
                          }

                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                selectedDate = DateTime(
                                  displayedMonth.year,
                                  displayedMonth.month,
                                  day,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFD5E9F6)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: selected
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x30000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$day',
                                style: const TextStyle(
                                  color: Color(0xFF16395B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.child,
    this.trailing,
  });

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
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
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

class _GoalProgressRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 10;
    final Rect arcRect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final Paint tealPaint = Paint()
      ..color = const Color(0xFF73D4C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint pinkPaint = Paint()
      ..color = const Color(0xFFE8A8A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFE8DFA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final double startAngle = -math.pi / 6;
    final double pinkSweep = math.pi / 2;
    final double yellowSweep = math.pi / 2;
    final double tealSweep = math.pi;

    canvas.drawArc(arcRect, startAngle, pinkSweep, false, pinkPaint);
    canvas.drawArc(
      arcRect,
      startAngle + pinkSweep,
      yellowSweep,
      false,
      yellowPaint,
    );
    canvas.drawArc(
      arcRect,
      startAngle + pinkSweep + yellowSweep,
      tealSweep,
      false,
      tealPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav({
    required this.currentIndex,
    required this.onSelected,
  });

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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.deepBlue,
          fontSize: 22,
          fontWeight: FontWeight.w700,
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
