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
    defaultValue: 'https://glucare-api.onrender.com',
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
}
