import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _mealChannelId = 'meal_reminders';
  static const String _mealChannelName = 'Meal Reminders';
  static const String _mealChannelDescription =
      'Nhắc đo đường huyết sau các bữa ăn';

  static const String _goalChannelId = 'goal_updates';
  static const String _goalChannelName = 'Goal Updates';
  static const String _goalChannelDescription =
      'Thông báo khi đạt mục tiêu đường huyết';

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);

    await _requestPermissions();
    await _configureTimezone();
    await scheduleDailyAfterMealReminders();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _configureTimezone() async {
    tzdata.initializeTimeZones();
    final TimezoneInfo timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  }

  Future<void> scheduleDailyAfterMealReminders() async {
    const List<_MealReminder> reminders = <_MealReminder>[
      _MealReminder(id: 1001, title: 'Bữa sáng', hour: 9, minute: 0),
      _MealReminder(id: 1002, title: 'Bữa trưa', hour: 14, minute: 0),
      _MealReminder(id: 1003, title: 'Bữa tối', hour: 20, minute: 0),
    ];

    for (final _MealReminder reminder in reminders) {
      await _notifications.zonedSchedule(
        id: reminder.id,
        title: 'GluCare',
        body: 'Nhớ đo đường huyết sau ăn nhé (${reminder.title})',
        scheduledDate: _nextInstanceOf(reminder.hour, reminder.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _mealChannelId,
            _mealChannelName,
            channelDescription: _mealChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> notifyWeeklyGoalReachedIfNeeded({
    required int glucoseGoalPercent,
    required int weeklyGoalPercent,
  }) async {
    if (glucoseGoalPercent != weeklyGoalPercent) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String weekKey = _currentWeekNotificationKey();
    if (prefs.getBool(weekKey) ?? false) {
      return;
    }

    await _notifications.show(
      id: 2001,
      title: 'GluCare',
      body: 'Bạn đã đạt mục tiêu tuần này! Tiếp tục duy trì nhé!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _goalChannelId,
          _goalChannelName,
          channelDescription: _goalChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    await prefs.setBool(weekKey, true);
  }

  String _currentWeekNotificationKey() {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    final int dayOfYear = now.difference(firstDayOfYear).inDays + 1;
    final int weekOfYear = ((dayOfYear - 1) / 7).floor() + 1;
    return 'weekly_goal_notified_${now.year}_$weekOfYear';
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

class _MealReminder {
  const _MealReminder({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
  });

  final int id;
  final String title;
  final int hour;
  final int minute;
}
