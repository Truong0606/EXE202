import 'dart:convert';

import 'package:first_app/core/models/dashboard_models.dart';
import 'package:first_app/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;

class BackendApiService {
  BackendApiService._();

  static final BackendApiService instance = BackendApiService._();
  final AuthStorageService _authStorageService = AuthStorageService.instance;

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://glucare-api.vercel.app',
  );

  Future<Map<String, dynamic>> registerPatient({
    required String phoneNumber,
    required String password,
    required String fullName,
    required String gender,
    required String dateOfBirth,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/auth/register/patient');
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'phoneNumber': phoneNumber,
        'password': password,
        'fullName': fullName,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return body;
    }

    final String message = (body['message'] ?? 'Đăng ký thất bại').toString();
    throw Exception(message);
  }

  Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/auth/login');
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode == 200) {
      return body;
    }

    final String message = (body['message'] ?? 'Đăng nhập thất bại').toString();
    throw Exception(message);
  }

  Future<Map<String, dynamic>> createGlucoseReading({
    required double glucoseValue,
    required String mealContext,
    required DateTime recordedAt,
    String readingType = 'MANUAL',
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/glucose');
    final Map<String, String> headers = await _authorizedHeaders();
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'glucoseValue': glucoseValue,
        'readingType': readingType,
        'mealContext': mealContext,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return body;
    }

    final String message =
        (body['message'] ?? 'Không thể lưu dữ liệu đường huyết').toString();
    throw Exception(message);
  }

  Future<Map<String, dynamic>> createMealEntry({
    required String foodName,
    required String mealType,
    required double calories,
    required double carbs,
    required DateTime recordedAt,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/meals');
    final Map<String, String> headers = await _authorizedHeaders();
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'foodName': foodName,
        'mealType': mealType,
        'calories': calories,
        'carbs': carbs,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return body;
    }

    final String message =
        (body['message'] ?? 'Không thể ghi nhận bữa ăn').toString();
    throw Exception(message);
  }

  Future<Map<String, dynamic>> createMedicationEntry({
    required String medicineName,
    required double dosage,
    required String unit,
    required DateTime recordedAt,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/medications');
    final Map<String, String> headers = await _authorizedHeaders();
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'medicineName': medicineName,
        'dosage': dosage,
        'unit': unit,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return body;
    }

    final String message =
        (body['message'] ?? 'Không thể ghi nhận uống thuốc').toString();
    throw Exception(message);
  }

  Future<BlogArticleData?> fetchLatestBlogArticle() async {
    final Map<String, dynamic>? json = await _getJson('/api/blog/latest');
    if (json == null) {
      return null;
    }
    return BlogArticleData.fromJson(json);
  }

  Future<List<FollowMemberData>> fetchFollowMembers() async {
    final dynamic response = await _getDynamic('/api/following/status');
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(FollowMemberData.fromJson)
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final dynamic list =
          response['data'] ?? response['items'] ?? response['members'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(FollowMemberData.fromJson)
            .toList();
      }
    }

    return const <FollowMemberData>[];
  }

  Future<UserProfileData?> fetchCurrentUserProfile() async {
    final Map<String, dynamic>? response = await _getJson('/v1/auth/me');
    if (response == null) {
      return null;
    }

    final Map<String, dynamic> data = _extractDataMap(response);
    if (data.isEmpty) {
      return null;
    }

    return UserProfileData.fromJson(data);
  }

  Future<List<GlucoseHistoryItemData>> fetchGlucoseHistory({
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, String> query = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (startDate != null) {
      query['startDate'] = _formatDateOnly(startDate);
    }
    if (endDate != null) {
      query['endDate'] = _formatDateOnly(endDate);
    }

    final Uri uri = Uri.parse(
      '$_baseUrl/v1/glucose/history',
    ).replace(queryParameters: query);
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const <GlucoseHistoryItemData>[];
    }

    final Map<String, dynamic> payload = _safeDecodeMap(response.body);
    final dynamic data = payload['data'];
    if (data is! List) {
      return const <GlucoseHistoryItemData>[];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(GlucoseHistoryItemData.fromJson)
        .toList();
  }

  Future<List<GlucoseHistoryItemData>> fetchGlucoseHistoryByDate(
    DateTime date,
  ) async {
    final DateTime target = DateTime(date.year, date.month, date.day);
    final DateTime nextDay = target.add(const Duration(days: 1));

    final List<GlucoseHistoryItemData> filteredRecords = await fetchGlucoseHistory(
      page: 1,
      limit: 10,
      startDate: target,
      endDate: nextDay,
    );

    final List<GlucoseHistoryItemData> unfilteredRecords = await fetchGlucoseHistory(
      page: 1,
      limit: 10,
    );

    final Map<String, GlucoseHistoryItemData> mergedById =
        <String, GlucoseHistoryItemData>{
          for (final GlucoseHistoryItemData item in filteredRecords) item.id: item,
          for (final GlucoseHistoryItemData item in unfilteredRecords) item.id: item,
        };

    final List<GlucoseHistoryItemData> records = mergedById.values.where((
      GlucoseHistoryItemData item,
    ) {
      final DateTime recordedLocal = item.recordedAt.toLocal();
      final bool inRecordedRange = !recordedLocal.isBefore(target) &&
          recordedLocal.isBefore(nextDay);

      final DateTime? createdLocal = item.createdAt?.toLocal();
      final bool inCreatedRange = createdLocal != null &&
          !createdLocal.isBefore(target) &&
          createdLocal.isBefore(nextDay);

      return inRecordedRange || inCreatedRange;
    }).toList();

    records.sort(
      (GlucoseHistoryItemData a, GlucoseHistoryItemData b) =>
          a.recordedAt.compareTo(b.recordedAt),
    );
    return records;
  }

  Future<List<GlucoseHistoryItemData>> fetchGlucoseHistoryLast24Hours() async {
    final List<GlucoseHistoryItemData> records = await fetchGlucoseHistory(
      page: 1,
      limit: 100,
    );
    final DateTime threshold = DateTime.now().toUtc().subtract(
      const Duration(hours: 24),
    );

    final List<GlucoseHistoryItemData> filtered = records
        .where((GlucoseHistoryItemData item) => item.recordedAt.isAfter(threshold))
        .toList();
    filtered.sort(
      (GlucoseHistoryItemData a, GlucoseHistoryItemData b) =>
          a.recordedAt.compareTo(b.recordedAt),
    );
    return filtered;
  }

  Future<GlucoseHistoryItemData?> fetchLatestGlucoseHistory() async {
    final List<GlucoseHistoryItemData> records = await fetchGlucoseHistory(
      page: 1,
      limit: 50,
    );
    if (records.isEmpty) {
      return null;
    }

    records.sort(
      (GlucoseHistoryItemData a, GlucoseHistoryItemData b) =>
          b.recordedAt.compareTo(a.recordedAt),
    );
    return records.first;
  }

  Future<double?> fetchWeeklyComplianceScore() async {
    final Uri uri = Uri.parse('$_baseUrl/v1/glucose/reports/summary?days=7');
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final Map<String, dynamic> payload = _safeDecodeMap(response.body);
    final dynamic data = payload['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final dynamic compliance = data['compliance'];
    if (compliance is! Map<String, dynamic>) {
      return null;
    }

    final dynamic score = compliance['score'];
    if (score is num) {
      return score.toDouble();
    }
    return double.tryParse(score?.toString() ?? '');
  }

  Future<GlucoseAnalyticsData?> fetchGlucoseAnalytics({int days = 1}) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/glucose/analytics?days=$days');
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final Map<String, dynamic> payload = _safeDecodeMap(response.body);
    final dynamic data = payload['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }

    return GlucoseAnalyticsData.fromJson(data);
  }

  Future<Map<String, dynamic>?> _getJson(String path) async {
    final dynamic response = await _getDynamic(path);
    return response is Map<String, dynamic> ? response : null;
  }

  Future<dynamic> _getDynamic(String path) async {
    final Uri uri = Uri.parse('$_baseUrl$path');
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> payload) {
    final dynamic data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return payload;
  }

  Map<String, dynamic> _safeDecodeMap(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final String? accessToken = await _authStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{'Authorization': 'Bearer $accessToken'};
  }

  String _formatDateOnly(DateTime value) {
    final DateTime local = value.toLocal();
    final String year = local.year.toString().padLeft(4, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
