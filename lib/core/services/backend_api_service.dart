import 'dart:convert';
import 'dart:io';

import 'package:first_app/core/models/dashboard_models.dart';
import 'package:first_app/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

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

  Future<void> forgotPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/auth/forgot-password');
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'phoneNumber': phoneNumber,
        'newPassword': newPassword,
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode == 200) {
      return;
    }

    final String message = (body['message'] ?? 'Không thể đặt lại mật khẩu')
        .toString();
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
      headers: <String, String>{...headers, 'Content-Type': 'application/json'},
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
      headers: <String, String>{...headers, 'Content-Type': 'application/json'},
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

    final String message = (body['message'] ?? 'Không thể ghi nhận bữa ăn')
        .toString();
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
      headers: <String, String>{...headers, 'Content-Type': 'application/json'},
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

    final String message = (body['message'] ?? 'Không thể ghi nhận uống thuốc')
        .toString();
    throw Exception(message);
  }

  Future<List<BlogArticleData>> fetchPublishedBlogArticles({
    int page = 1,
    int limit = 20,
    String language = 'VI',
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/patient/articles').replace(
      queryParameters: <String, String>{
        'page': '$page',
        'limit': '$limit',
        'language': language,
      },
    );
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = (body['message'] ?? 'Không thể tải bài viết')
          .toString();
      throw Exception(message);
    }

    return _extractDataList(body)
        .map(BlogArticleData.fromJson)
        .where((BlogArticleData article) => article.title.trim().isNotEmpty)
        .toList();
  }

  Future<BlogArticleData?> fetchBlogArticleDetail(String articleId) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/patient/articles/$articleId');
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message =
          (body['message'] ?? 'Không thể tải chi tiết bài viết').toString();
      throw Exception(message);
    }

    final Map<String, dynamic> articleDetail = _extractDataMap(body);
    if (articleDetail.isEmpty) {
      return null;
    }

    return BlogArticleData.fromJson(articleDetail);
  }

  Future<BlogArticleData?> fetchLatestBlogArticle() async {
    final List<BlogArticleData> articles = await fetchPublishedBlogArticles(
      page: 1,
      limit: 1,
    );
    if (articles.isEmpty) {
      return null;
    }

    final BlogArticleData articleSummary = articles.first;
    final String articleId = articleSummary.id.trim();
    if (articleId.isEmpty) {
      return articleSummary;
    }

    final BlogArticleData? articleDetail = await fetchBlogArticleDetail(
      articleId,
    );
    if (articleDetail == null) {
      return articleSummary;
    }

    return BlogArticleData.fromJson(<String, dynamic>{
      'id': articleSummary.id,
      'title': articleSummary.title,
      'publishedInfo': articleSummary.publishedInfo,
      'summary': articleSummary.summary,
      'body': articleDetail.body,
      'imageUrl': articleDetail.imageUrl ?? articleSummary.imageUrl,
    });
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
    final Map<String, dynamic>? response =
        await _getJson('/v1/profile') ?? await _getJson('/v1/auth/me');
    if (response == null) {
      return null;
    }

    final Map<String, dynamic> data = _extractDataMap(response);
    if (data.isEmpty) {
      return null;
    }

    return UserProfileData.fromJson(data);
  }

  Future<UserProfileData?> updateCurrentUserProfile({
    required String fullName,
    String? gender,
    String? dateOfBirth,
    String? specialization,
    String? hospital,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/profile');
    final http.Response response = await http.patch(
      uri,
      headers: <String, String>{
        ...await _authorizedHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'fullName': fullName,
        if ((gender ?? '').trim().isNotEmpty) 'gender': gender,
        if ((dateOfBirth ?? '').trim().isNotEmpty) 'dateOfBirth': dateOfBirth,
        if ((specialization ?? '').trim().isNotEmpty)
          'specialization': specialization,
        if ((hospital ?? '').trim().isNotEmpty) 'hospital': hospital,
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = (body['message'] ?? 'Không thể cập nhật hồ sơ')
          .toString();
      throw Exception(message);
    }

    final Map<String, dynamic> data = _extractDataMap(body);
    if (data.isEmpty) {
      return fetchCurrentUserProfile();
    }
    return UserProfileData.fromJson(data);
  }

  Future<UserProfileData?> uploadProfileAvatar(File avatarFile) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/profile/avatar');
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authorizedHeaders());

    final String? mimeType = lookupMimeType(avatarFile.path);
    MediaType? contentType;
    if ((mimeType ?? '').contains('/')) {
      final List<String> parts = mimeType!.split('/');
      if (parts.length == 2) {
        contentType = MediaType(parts[0], parts[1]);
      }
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        avatarFile.path,
        contentType: contentType,
      ),
    );

    final http.Response response = await http.Response.fromStream(
      await request.send(),
    );
    final Map<String, dynamic> body = _safeDecodeMap(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = (body['message'] ?? 'Không thể tải ảnh đại diện')
          .toString();
      throw Exception(message);
    }

    final Map<String, dynamic> data = _extractDataMap(body);
    if (data.isNotEmpty) {
      return UserProfileData.fromJson(data);
    }

    return fetchCurrentUserProfile();
  }

  Future<PaymentInitiationData> initiatePayment({
    required String userId,
    required String packageType,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/payments/initiate');
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        ...await _authorizedHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'packageType': packageType,
      }),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message =
          (body['message'] ?? 'Không thể khởi tạo thanh toán').toString();
      throw Exception(message);
    }

    final Map<String, dynamic> data = _extractDataMap(body);
    final PaymentInitiationData result = PaymentInitiationData.fromJson(
      data.isEmpty ? body : data,
    );
    if (result.paymentUrl.trim().isEmpty) {
      throw Exception('API chưa trả về liên kết thanh toán hợp lệ');
    }
    return result;
  }

  Future<List<PaymentHistoryItemData>> fetchPaymentHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final Map<String, String> query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if ((status ?? '').trim().isNotEmpty) 'status': status!.trim(),
    };
    final Uri uri = Uri.parse(
      '$_baseUrl/v1/payments/history',
    ).replace(queryParameters: query);
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message =
          (body['message'] ?? 'Không thể tải lịch sử thanh toán').toString();
      throw Exception(message);
    }

    final List<Map<String, dynamic>> items = _extractDataList(body);
    final List<PaymentHistoryItemData> history = items
        .map(PaymentHistoryItemData.fromJson)
        .where(
          (PaymentHistoryItemData item) =>
              item.id.isNotEmpty || item.packageType.isNotEmpty,
        )
        .toList();

    history.sort((PaymentHistoryItemData first, PaymentHistoryItemData second) {
      final DateTime firstDate =
          first.createdAt ??
          first.paidAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime secondDate =
          second.createdAt ??
          second.paidAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return secondDate.compareTo(firstDate);
    });
    return history;
  }

  Future<void> cancelPendingPayment({String? transactionId}) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/payments/cancel');
    final Map<String, dynamic> payload = <String, dynamic>{
      if ((transactionId ?? '').trim().isNotEmpty)
        'transactionId': transactionId!.trim(),
    };

    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        ...await _authorizedHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = (body['message'] ?? 'Không thể hủy giao dịch chờ')
          .toString();
      throw Exception(message);
    }
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

    final List<GlucoseHistoryItemData> filteredRecords =
        await fetchGlucoseHistory(
          page: 1,
          limit: 10,
          startDate: target,
          endDate: nextDay,
        );

    final List<GlucoseHistoryItemData> unfilteredRecords =
        await fetchGlucoseHistory(page: 1, limit: 10);

    final Map<String, GlucoseHistoryItemData> mergedById =
        <String, GlucoseHistoryItemData>{
          for (final GlucoseHistoryItemData item in filteredRecords)
            item.id: item,
          for (final GlucoseHistoryItemData item in unfilteredRecords)
            item.id: item,
        };

    final List<GlucoseHistoryItemData> records = mergedById.values.where((
      GlucoseHistoryItemData item,
    ) {
      final DateTime recordedLocal = item.recordedAt.toLocal();
      final bool inRecordedRange =
          !recordedLocal.isBefore(target) && recordedLocal.isBefore(nextDay);

      final DateTime? createdLocal = item.createdAt?.toLocal();
      final bool inCreatedRange =
          createdLocal != null &&
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
        .where(
          (GlucoseHistoryItemData item) => item.recordedAt.isAfter(threshold),
        )
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

  Future<AiChatResultData> sendAiChatMessage({
    String? message,
    String? sessionId,
    File? file,
  }) async {
    final String trimmedMessage = (message ?? '').trim();
    final String trimmedSessionId = (sessionId ?? '').trim();
    if (trimmedMessage.isEmpty && file == null) {
      throw Exception('Vui lòng nhập tin nhắn hoặc đính kèm tệp');
    }

    final Uri uri = Uri.parse('$_baseUrl/v1/ai/chat');
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authorizedHeaders());

    if (trimmedMessage.isNotEmpty) {
      request.fields['message'] = trimmedMessage;
    }
    if (trimmedSessionId.isNotEmpty) {
      request.fields['sessionId'] = trimmedSessionId;
    }
    if (file != null) {
      final MediaType? contentType = _resolveUploadContentType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: _fileNameFromPath(file.path),
          contentType: contentType,
        ),
      );
    }

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(
      streamedResponse,
    );
    final Map<String, dynamic> body = _safeDecodeMap(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = _extractDataMap(body);
      return AiChatResultData.fromJson(data);
    }

    final String messageText =
        (body['message'] ?? 'Không thể gửi tin nhắn tới AI').toString();
    throw Exception(messageText);
  }

  Future<List<AiChatSessionSummaryData>> fetchAiSessions() async {
    final dynamic response = await _getDynamic('/v1/ai/sessions');
    final List<Map<String, dynamic>> items = _extractDataList(response);
    final List<AiChatSessionSummaryData> sessions = items
        .map(AiChatSessionSummaryData.fromJson)
        .where((AiChatSessionSummaryData item) => item.id.isNotEmpty)
        .toList();

    sessions.sort((
      AiChatSessionSummaryData first,
      AiChatSessionSummaryData second,
    ) {
      final DateTime firstUpdated =
          first.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime secondUpdated =
          second.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondUpdated.compareTo(firstUpdated);
    });
    return sessions;
  }

  Future<List<AiChatMessageData>> fetchAiSessionMessages(
    String sessionId, {
    int page = 1,
    int limit = 100,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/v1/ai/sessions/$sessionId/messages?page=$page&limit=$limit',
    );
    final http.Response response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const <AiChatMessageData>[];
    }

    final dynamic payload = jsonDecode(response.body);
    final List<Map<String, dynamic>> items = _extractDataList(payload);
    final List<AiChatMessageData> messages = items
        .map(AiChatMessageData.fromJson)
        .where(
          (AiChatMessageData item) =>
              item.text.isNotEmpty || item.attachmentName != null,
        )
        .toList();

    messages.sort((AiChatMessageData first, AiChatMessageData second) {
      final DateTime firstCreated =
          first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime secondCreated =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return firstCreated.compareTo(secondCreated);
    });
    return messages;
  }

  Future<void> renameAiSession(String sessionId, String title) async {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Tên cuộc trò chuyện không được để trống');
    }

    final Uri uri = Uri.parse('$_baseUrl/v1/ai/sessions/$sessionId');
    final http.Response response = await http.patch(
      uri,
      headers: <String, String>{
        ...await _authorizedHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{'title': trimmedTitle}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    final String message =
        (body['message'] ?? 'Không thể đổi tên cuộc trò chuyện').toString();
    throw Exception(message);
  }

  Future<void> deleteAiSession(String sessionId) async {
    final Uri uri = Uri.parse('$_baseUrl/v1/ai/sessions/$sessionId');
    final http.Response response = await http.delete(
      uri,
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final Map<String, dynamic> body = _safeDecodeMap(response.body);
    final String message = (body['message'] ?? 'Không thể xóa cuộc trò chuyện')
        .toString();
    throw Exception(message);
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

  List<Map<String, dynamic>> _extractDataList(dynamic payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    if (payload is Map<String, dynamic>) {
      final dynamic data = payload['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      if (data is Map<String, dynamic>) {
        final dynamic nestedList =
            data['items'] ??
            data['list'] ??
            data['results'] ??
            data['history'] ??
            data['messages'] ??
            data['sessions'] ??
            data['payments'] ??
            data['transactions'];
        if (nestedList is List) {
          return nestedList.whereType<Map<String, dynamic>>().toList();
        }
      }

      final dynamic directList =
          payload['items'] ??
          payload['list'] ??
          payload['results'] ??
          payload['history'] ??
          payload['messages'] ??
          payload['sessions'] ??
          payload['payments'] ??
          payload['transactions'];
      if (directList is List) {
        return directList.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const <Map<String, dynamic>>[];
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

  MediaType? _resolveUploadContentType(String filePath) {
    final String? mimeType = lookupMimeType(filePath);
    if (mimeType == null || !mimeType.contains('/')) {
      return null;
    }

    final List<String> parts = mimeType.split('/');
    if (parts.length != 2) {
      return null;
    }

    return MediaType(parts[0], parts[1]);
  }

  String _fileNameFromPath(String filePath) {
    final List<String> segments = filePath.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? filePath : segments.last;
  }
}

class AiChatResultData {
  const AiChatResultData({
    required this.reply,
    this.sessionId,
    this.rawData = const <String, dynamic>{},
  });

  final String reply;
  final String? sessionId;
  final Map<String, dynamic> rawData;

  factory AiChatResultData.fromJson(Map<String, dynamic> json) {
    String? firstNonEmptyString(List<dynamic> values) {
      for (final dynamic value in values) {
        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
      return null;
    }

    Map<String, dynamic>? asMap(dynamic value) {
      return value is Map<String, dynamic> ? value : null;
    }

    final Map<String, dynamic>? result = asMap(json['result']);
    final Map<String, dynamic>? message = asMap(json['message']);
    final Map<String, dynamic>? assistantMessage = asMap(
      json['assistantMessage'],
    );
    final Map<String, dynamic>? response = asMap(json['response']);

    final String reply =
        firstNonEmptyString(<dynamic>[
          json['reply'],
          json['responseText'],
          json['assistantReply'],
          json['content'],
          json['text'],
          json['message'],
          result?['reply'],
          result?['responseText'],
          result?['assistantReply'],
          result?['content'],
          result?['text'],
          message?['content'],
          message?['text'],
          assistantMessage?['content'],
          assistantMessage?['text'],
          response?['content'],
          response?['text'],
        ]) ??
        'Mình đã nhận được thông tin của bạn.';

    final String? sessionId = firstNonEmptyString(<dynamic>[
      json['sessionId'],
      json['threadId'],
      result?['sessionId'],
      result?['threadId'],
      message?['sessionId'],
      response?['sessionId'],
    ]);

    return AiChatResultData(reply: reply, sessionId: sessionId, rawData: json);
  }
}

class AiChatSessionSummaryData {
  const AiChatSessionSummaryData({
    required this.id,
    required this.title,
    this.updatedAt,
    this.preview,
  });

  final String id;
  final String title;
  final DateTime? updatedAt;
  final String? preview;

  factory AiChatSessionSummaryData.fromJson(Map<String, dynamic> json) {
    final String id = _readFirstString(json, <String>[
      'id',
      'sessionId',
      'threadId',
    ]);
    final String title = _readFirstString(json, <String>[
      'title',
      'name',
      'sessionTitle',
    ], fallback: 'Cuộc trò chuyện');
    return AiChatSessionSummaryData(
      id: id,
      title: title,
      updatedAt: _readFirstDateTime(json, <String>[
        'updatedAt',
        'lastMessageAt',
        'createdAt',
      ]),
      preview: _readNullableString(json, <String>[
        'preview',
        'lastMessage',
        'content',
        'message',
      ]),
    );
  }
}

class AiChatMessageData {
  const AiChatMessageData({
    required this.text,
    required this.isUser,
    this.attachmentName,
    this.createdAt,
    this.disclaimer,
  });

  final String text;
  final bool isUser;
  final String? attachmentName;
  final DateTime? createdAt;
  final String? disclaimer;

  factory AiChatMessageData.fromJson(Map<String, dynamic> json) {
    final String role = _readFirstString(json, <String>[
      'role',
      'senderRole',
      'authorRole',
      'type',
    ], fallback: '').toLowerCase();
    final bool isUser =
        json['isUser'] == true ||
        role.contains('user') ||
        role.contains('patient') ||
        role.contains('human');

    final dynamic attachment =
        json['file'] ?? json['attachment'] ?? json['media'];
    String? attachmentName;
    if (attachment is Map<String, dynamic>) {
      attachmentName = _readNullableString(attachment, <String>[
        'name',
        'fileName',
        'originalName',
      ]);
    }

    return AiChatMessageData(
      text: _readFirstString(json, <String>[
        'content',
        'text',
        'message',
        'body',
      ], fallback: ''),
      isUser: isUser,
      attachmentName: attachmentName,
      createdAt: _readFirstDateTime(json, <String>[
        'createdAt',
        'updatedAt',
        'sentAt',
      ]),
      disclaimer: _readNullableString(json, <String>[
        'medicalDisclaimer',
        'disclaimer',
      ]),
    );
  }
}

String _readFirstString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final String key in keys) {
    final String value = (json[key] ?? '').toString().trim();
    if (value.isNotEmpty && value.toLowerCase() != 'null') {
      return value;
    }
  }
  return fallback;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  final String value = _readFirstString(json, keys);
  return value.isEmpty ? null : value;
}

DateTime? _readFirstDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final String raw = (json[key] ?? '').toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      continue;
    }

    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}
