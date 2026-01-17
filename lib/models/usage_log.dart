class UsageLog {
  final String id;
  final String vocabularyItemId;
  final DateTime timestamp;
  final String languageCode;
  final String? sentence; // Full sentence if multiple words selected
  final Duration? sessionDuration; // Time spent in session

  UsageLog({
    required this.id,
    required this.vocabularyItemId,
    required this.timestamp,
    required this.languageCode,
    this.sentence,
    this.sessionDuration,
  });

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    return UsageLog(
      id: json['id'] as String,
      vocabularyItemId: json['vocabularyItemId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      languageCode: json['languageCode'] as String,
      sentence: json['sentence'] as String?,
      sessionDuration: json['sessionDuration'] != null
          ? Duration(microseconds: json['sessionDuration'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vocabularyItemId': vocabularyItemId,
      'timestamp': timestamp.toIso8601String(),
      'languageCode': languageCode,
      'sentence': sentence,
      'sessionDuration': sessionDuration?.inMicroseconds,
    };
  }
}

class UsageStatistics {
  final Map<String, int> wordUsageCount; // wordId -> count
  final Map<String, int> categoryUsageCount; // category -> count
  final DateTime? firstUsageDate;
  final DateTime? lastUsageDate;
  final int totalSessions;
  final Duration totalUsageTime;
  final List<String> mostUsedWords; // Top N words
  final List<String> recentWords; // Recently used words

  UsageStatistics({
    this.wordUsageCount = const {},
    this.categoryUsageCount = const {},
    this.firstUsageDate,
    this.lastUsageDate,
    this.totalSessions = 0,
    this.totalUsageTime = Duration.zero,
    this.mostUsedWords = const [],
    this.recentWords = const [],
  });

  factory UsageStatistics.fromJson(Map<String, dynamic> json) {
    return UsageStatistics(
      wordUsageCount: (json['wordUsageCount'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          const {},
      categoryUsageCount: (json['categoryUsageCount'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          const {},
      firstUsageDate: json['firstUsageDate'] != null
          ? DateTime.parse(json['firstUsageDate'] as String)
          : null,
      lastUsageDate: json['lastUsageDate'] != null
          ? DateTime.parse(json['lastUsageDate'] as String)
          : null,
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalUsageTime: Duration(microseconds: json['totalUsageTime'] as int? ?? 0),
      mostUsedWords: (json['mostUsedWords'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      recentWords: (json['recentWords'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordUsageCount': wordUsageCount,
      'categoryUsageCount': categoryUsageCount,
      'firstUsageDate': firstUsageDate?.toIso8601String(),
      'lastUsageDate': lastUsageDate?.toIso8601String(),
      'totalSessions': totalSessions,
      'totalUsageTime': totalUsageTime.inMicroseconds,
      'mostUsedWords': mostUsedWords,
      'recentWords': recentWords,
    };
  }
}

