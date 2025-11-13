// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageLog _$UsageLogFromJson(Map<String, dynamic> json) => UsageLog(
  id: json['id'] as String,
  vocabularyItemId: json['vocabularyItemId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  languageCode: json['languageCode'] as String,
  sentence: json['sentence'] as String?,
  sessionDuration: json['sessionDuration'] == null
      ? null
      : Duration(microseconds: (json['sessionDuration'] as num).toInt()),
);

Map<String, dynamic> _$UsageLogToJson(UsageLog instance) => <String, dynamic>{
  'id': instance.id,
  'vocabularyItemId': instance.vocabularyItemId,
  'timestamp': instance.timestamp.toIso8601String(),
  'languageCode': instance.languageCode,
  'sentence': instance.sentence,
  'sessionDuration': instance.sessionDuration?.inMicroseconds,
};

UsageStatistics _$UsageStatisticsFromJson(Map<String, dynamic> json) =>
    UsageStatistics(
      wordUsageCount:
          (json['wordUsageCount'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      categoryUsageCount:
          (json['categoryUsageCount'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      firstUsageDate: json['firstUsageDate'] == null
          ? null
          : DateTime.parse(json['firstUsageDate'] as String),
      lastUsageDate: json['lastUsageDate'] == null
          ? null
          : DateTime.parse(json['lastUsageDate'] as String),
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalUsageTime: json['totalUsageTime'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalUsageTime'] as num).toInt()),
      mostUsedWords:
          (json['mostUsedWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recentWords:
          (json['recentWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UsageStatisticsToJson(UsageStatistics instance) =>
    <String, dynamic>{
      'wordUsageCount': instance.wordUsageCount,
      'categoryUsageCount': instance.categoryUsageCount,
      'firstUsageDate': instance.firstUsageDate?.toIso8601String(),
      'lastUsageDate': instance.lastUsageDate?.toIso8601String(),
      'totalSessions': instance.totalSessions,
      'totalUsageTime': instance.totalUsageTime.inMicroseconds,
      'mostUsedWords': instance.mostUsedWords,
      'recentWords': instance.recentWords,
    };

