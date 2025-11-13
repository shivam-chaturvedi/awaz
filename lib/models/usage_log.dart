import 'package:json_annotation/json_annotation.dart';

part 'usage_log.g.dart';

@JsonSerializable()
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

  factory UsageLog.fromJson(Map<String, dynamic> json) =>
      _$UsageLogFromJson(json);

  Map<String, dynamic> toJson() => _$UsageLogToJson(this);
}

@JsonSerializable()
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

  factory UsageStatistics.fromJson(Map<String, dynamic> json) =>
      _$UsageStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageStatisticsToJson(this);
}


