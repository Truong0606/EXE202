class BlogArticleData {
  const BlogArticleData({
    required this.id,
    required this.title,
    required this.publishedInfo,
    required this.summary,
    required this.body,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String publishedInfo;
  final String summary;
  final List<String> body;
  final String? imageUrl;

  factory BlogArticleData.fromJson(Map<String, dynamic> json) {
    final dynamic bodyRaw =
        json['body'] ?? json['content'] ?? json['paragraphs'];
    final List<String> paragraphs;
    if (bodyRaw is List) {
      paragraphs = bodyRaw.map((dynamic item) => item.toString()).toList();
    } else if (bodyRaw is String) {
      final String normalized = bodyRaw
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'");
      paragraphs = normalized
          .split(RegExp(r'\n\s*\n|\r\n\s*\r\n'))
          .map((String part) => part.replaceAll(RegExp(r'\s+'), ' ').trim())
          .where((String part) => part.isNotEmpty)
          .toList();
    } else {
      paragraphs = <String>[];
    }

    final String summary =
        (json['summary'] ??
                json['description'] ??
                json['excerpt'] ??
                json['shortDescription'] ??
                '')
            .toString()
            .trim();
    final String fallbackSummary = paragraphs.isEmpty
        ? ''
        : paragraphs.first.length > 180
        ? '${paragraphs.first.substring(0, 180).trim()}...'
        : paragraphs.first;

    return BlogArticleData(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      publishedInfo:
          (json['publishedInfo'] ??
                  json['published_at'] ??
                  json['publishedAt'] ??
                  json['createdAt'] ??
                  '')
              .toString(),
      summary: summary.isEmpty ? fallbackSummary : summary,
      body: paragraphs,
      imageUrl:
          (json['imageUrl'] ??
                  json['image_url'] ??
                  json['thumbnailUrl'] ??
                  json['thumbnail_url'] ??
                  '')
              .toString()
              .isEmpty
          ? null
          : (json['imageUrl'] ??
                    json['image_url'] ??
                    json['thumbnailUrl'] ??
                    json['thumbnail_url'])
                .toString(),
    );
  }
}

class FollowMemberData {
  const FollowMemberData({
    required this.name,
    required this.glucoseText,
    required this.level,
    required this.isDanger,
  });

  final String name;
  final String glucoseText;
  final String level;
  final bool isDanger;

  factory FollowMemberData.fromJson(Map<String, dynamic> json) {
    final String level = (json['level'] ?? json['status'] ?? 'Bình thường')
        .toString();
    return FollowMemberData(
      name: (json['name'] ?? '').toString(),
      glucoseText: (json['glucoseText'] ?? json['glucose'] ?? '').toString(),
      level: level,
      isDanger: level.toLowerCase() == 'nguy hiểm',
    );
  }
}

class UserProfileData {
  const UserProfileData({
    required this.id,
    required this.phoneNumber,
    required this.role,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.status,
    this.gender,
    this.dateOfBirth,
    this.specialization,
    this.hospital,
  });

  final String id;
  final String phoneNumber;
  final String role;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? status;
  final String? gender;
  final String? dateOfBirth;
  final String? specialization;
  final String? hospital;

  UserProfileData copyWith({
    String? id,
    String? phoneNumber,
    String? role,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? status,
    String? gender,
    String? dateOfBirth,
    String? specialization,
    String? hospital,
  }) {
    return UserProfileData(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specialization: specialization ?? this.specialization,
      hospital: hospital ?? this.hospital,
    );
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> nestedProfile =
        (json['profile'] is Map<String, dynamic>)
        ? json['profile'] as Map<String, dynamic>
        : <String, dynamic>{};
    final Map<String, dynamic> patient =
        (json['patient'] is Map<String, dynamic>)
        ? json['patient'] as Map<String, dynamic>
        : <String, dynamic>{};
    final Map<String, dynamic> doctor = (json['doctor'] is Map<String, dynamic>)
        ? json['doctor'] as Map<String, dynamic>
        : <String, dynamic>{};

    String? nonEmpty(dynamic value) {
      final String text = (value ?? '').toString().trim();
      return text.isEmpty ? null : text;
    }

    return UserProfileData(
      id: (json['id'] ?? nestedProfile['id'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? nestedProfile['phoneNumber'] ?? '')
          .toString(),
      role: (json['role'] ?? nestedProfile['role'] ?? '').toString(),
      fullName:
          (json['fullName'] ??
                  nestedProfile['fullName'] ??
                  patient['fullName'] ??
                  doctor['fullName'] ??
                  '')
              .toString(),
      email: nonEmpty(json['email'] ?? nestedProfile['email']),
      avatarUrl: nonEmpty(
        json['avatarUrl'] ?? json['avatar'] ?? nestedProfile['avatarUrl'],
      ),
      status: nonEmpty(json['status'] ?? nestedProfile['status']),
      gender: nonEmpty(
        json['gender'] ?? patient['gender'] ?? nestedProfile['gender'],
      ),
      dateOfBirth: nonEmpty(
        json['dateOfBirth'] ??
            patient['dateOfBirth'] ??
            nestedProfile['dateOfBirth'],
      ),
      specialization: nonEmpty(
        json['specialization'] ??
            doctor['specialization'] ??
            nestedProfile['specialization'],
      ),
      hospital: nonEmpty(
        json['hospital'] ?? doctor['hospital'] ?? nestedProfile['hospital'],
      ),
    );
  }
}

class PaymentInitiationData {
  const PaymentInitiationData({
    required this.paymentUrl,
    this.transactionId,
    this.rawData = const <String, dynamic>{},
  });

  final String paymentUrl;
  final String? transactionId;
  final Map<String, dynamic> rawData;

  factory PaymentInitiationData.fromJson(Map<String, dynamic> json) {
    String? firstNonEmpty(List<dynamic> values) {
      for (final dynamic value in values) {
        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
      return null;
    }

    final String paymentUrl =
        firstNonEmpty(<dynamic>[
          json['paymentUrl'],
          json['url'],
          json['checkoutUrl'],
          json['redirectUrl'],
          json['paymentLink'],
          json['link'],
        ]) ??
        '';

    return PaymentInitiationData(
      paymentUrl: paymentUrl,
      transactionId: firstNonEmpty(<dynamic>[
        json['transactionId'],
        json['id'],
        json['paymentId'],
      ]),
      rawData: json,
    );
  }
}

class PaymentHistoryItemData {
  const PaymentHistoryItemData({
    required this.id,
    required this.packageType,
    required this.status,
    this.amount,
    this.currency,
    this.paymentUrl,
    this.createdAt,
    this.paidAt,
    this.expiresAt,
    this.isActive = false,
    this.rawData = const <String, dynamic>{},
  });

  final String id;
  final String packageType;
  final String status;
  final double? amount;
  final String? currency;
  final String? paymentUrl;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final DateTime? expiresAt;
  final bool isActive;
  final Map<String, dynamic> rawData;

  factory PaymentHistoryItemData.fromJson(Map<String, dynamic> json) {
    String? firstNonEmpty(List<dynamic> values) {
      for (final dynamic value in values) {
        final String text = (value ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse((value ?? '').toString().trim());
    }

    DateTime? parseDate(dynamic value) {
      final String text = (value ?? '').toString().trim();
      if (text.isEmpty) {
        return null;
      }
      return DateTime.tryParse(text);
    }

    bool? parseBool(dynamic value) {
      if (value is bool) {
        return value;
      }
      final String text = (value ?? '').toString().trim().toLowerCase();
      if (text == 'true' || text == '1') {
        return true;
      }
      if (text == 'false' || text == '0') {
        return false;
      }
      return null;
    }

    final String status =
        firstNonEmpty(<dynamic>[
          json['status'],
          json['paymentStatus'],
          json['subscriptionStatus'],
        ])?.toUpperCase() ??
        'UNKNOWN';
    final String packageType =
        firstNonEmpty(<dynamic>[
          json['packageType'],
          json['package'],
          json['packageCode'],
          json['subscriptionType'],
          json['planCode'],
        ])?.toUpperCase() ??
        '';
    final DateTime? expiresAt = parseDate(
      json['expiresAt'] ?? json['expiredAt'] ?? json['endDate'],
    );
    final bool isActive =
        parseBool(json['isActive'] ?? json['active']) ??
        status == 'ACTIVE' ||
            (status == 'SUCCESS' &&
                ((packageType == 'L') ||
                    (expiresAt != null && expiresAt.isAfter(DateTime.now()))));

    return PaymentHistoryItemData(
      id:
          firstNonEmpty(<dynamic>[
            json['transactionId'],
            json['id'],
            json['paymentId'],
            json['referenceCode'],
          ]) ??
          '',
      packageType: packageType,
      status: status,
      amount: parseDouble(
        json['amount'] ??
            json['price'] ??
            json['transferAmount'] ??
            json['paidAmount'] ??
            json['packagePrice'],
      ),
      currency: firstNonEmpty(<dynamic>[
        json['currency'],
        json['currencyCode'],
      ]),
      paymentUrl: firstNonEmpty(<dynamic>[
        json['paymentUrl'],
        json['url'],
        json['checkoutUrl'],
        json['redirectUrl'],
      ]),
      createdAt: parseDate(
        json['createdAt'] ?? json['transactionDate'] ?? json['created_at'],
      ),
      paidAt: parseDate(
        json['paidAt'] ?? json['completedAt'] ?? json['paid_at'],
      ),
      expiresAt: expiresAt,
      isActive: isActive,
      rawData: json,
    );
  }
}

class GlucoseHistoryItemData {
  const GlucoseHistoryItemData({
    required this.id,
    required this.glucoseValue,
    required this.readingType,
    required this.mealContext,
    required this.recordedAt,
    this.createdAt,
  });

  final String id;
  final double glucoseValue;
  final String readingType;
  final String mealContext;
  final DateTime recordedAt;
  final DateTime? createdAt;

  factory GlucoseHistoryItemData.fromJson(Map<String, dynamic> json) {
    final String glucoseText = (json['glucoseValue'] ?? '0').toString();
    final double glucoseValue = double.tryParse(glucoseText) ?? 0;
    final DateTime recordedAt =
        DateTime.tryParse((json['recordedAt'] ?? '').toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final DateTime? createdAt = DateTime.tryParse(
      (json['createdAt'] ?? '').toString(),
    );

    return GlucoseHistoryItemData(
      id: (json['id'] ?? '').toString(),
      glucoseValue: glucoseValue,
      readingType: (json['readingType'] ?? '').toString(),
      mealContext: (json['mealContext'] ?? '').toString(),
      recordedAt: recordedAt,
      createdAt: createdAt,
    );
  }
}

class GlucoseAnalyticsData {
  const GlucoseAnalyticsData({
    required this.tir,
    required this.hba1c,
    required this.chartValues,
  });

  final double? tir;
  final double? hba1c;
  final List<double> chartValues;

  factory GlucoseAnalyticsData.fromJson(Map<String, dynamic> json) {
    final dynamic stats = json['stats'];
    final dynamic chartData = json['chartData'];

    double? parseNum(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value?.toString() ?? '');
    }

    final List<double> values = chartData is List
        ? chartData
              .whereType<Map<String, dynamic>>()
              .map((Map<String, dynamic> item) => parseNum(item['value']))
              .whereType<double>()
              .toList()
        : const <double>[];

    return GlucoseAnalyticsData(
      tir: stats is Map<String, dynamic> ? parseNum(stats['tir']) : null,
      hba1c: parseNum(json['hba1c']),
      chartValues: values,
    );
  }
}
