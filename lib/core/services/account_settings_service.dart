import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsService {
  AccountSettingsService._();

  static final AccountSettingsService instance = AccountSettingsService._();

  static const String _notificationsEnabledKey =
      'account_notifications_enabled';
  static const String _remindersEnabledKey = 'account_reminders_enabled';
    static const String _paymentPromoShownAtPrefix =
      'account_payment_promo_shown_at_';

  Future<bool> getNotificationsEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  Future<bool> getRemindersEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersEnabledKey) ?? true;
  }

  Future<void> setRemindersEnabled(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersEnabledKey, value);
  }

  Future<DateTime?> getPaymentPromoShownAt(String userKey) async {
    final String normalizedKey = userKey.trim();
    if (normalizedKey.isEmpty) {
      return null;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storedValue =
        prefs.getString('$_paymentPromoShownAtPrefix$normalizedKey') ?? '';
    if (storedValue.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(storedValue);
  }

  Future<void> setPaymentPromoShownAt(String userKey, DateTime shownAt) async {
    final String normalizedKey = userKey.trim();
    if (normalizedKey.isEmpty) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_paymentPromoShownAtPrefix$normalizedKey',
      shownAt.toIso8601String(),
    );
  }
}
