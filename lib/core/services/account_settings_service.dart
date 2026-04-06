import 'package:first_app/core/models/dashboard_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsService {
  AccountSettingsService._();

  static final AccountSettingsService instance = AccountSettingsService._();

  static const String _notificationsEnabledKey =
      'account_notifications_enabled';
  static const String _remindersEnabledKey = 'account_reminders_enabled';
  static const String _profileNameKey = 'account_profile_name';
  static const String _profileEmailKey = 'account_profile_email';

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

  Future<UserProfileData> applyProfileOverrides(UserProfileData profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storedName = (prefs.getString(_profileNameKey) ?? '').trim();
    final String storedEmail = (prefs.getString(_profileEmailKey) ?? '').trim();

    return profile.copyWith(
      fullName: storedName.isEmpty ? null : storedName,
      email: storedEmail.isEmpty ? null : storedEmail,
    );
  }

  Future<void> saveProfileOverrides({
    required String fullName,
    String? email,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileNameKey, fullName.trim());
    await prefs.setString(_profileEmailKey, (email ?? '').trim());
  }
}