// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocabularyItem _$VocabularyItemFromJson(Map<String, dynamic> json) =>
    VocabularyItem(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      labels: Map<String, String>.from(json['labels'] as Map),
      category: json['category'] as String,
      parentId: json['parentId'] as String?,
      relatedWordIds:
          (json['relatedWordIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tapCount: (json['tapCount'] as num?)?.toInt() ?? 0,
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      colorScheme:
          $enumDecodeNullable(
            _$VocabularyColorSchemeEnumMap,
            json['colorScheme'],
          ) ??
          VocabularyColorScheme.blue,
      gridPosition: (json['gridPosition'] as num?)?.toInt(),
      isFrozen: json['isFrozen'] as bool? ?? false,
    );

Map<String, dynamic> _$VocabularyItemToJson(VocabularyItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'imageUrl': instance.imageUrl,
      'labels': instance.labels,
      'category': instance.category,
      'parentId': instance.parentId,
      'relatedWordIds': instance.relatedWordIds,
      'tapCount': instance.tapCount,
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'colorScheme': _$VocabularyColorSchemeEnumMap[instance.colorScheme]!,
      'gridPosition': instance.gridPosition,
      'isFrozen': instance.isFrozen,
    };

const _$VocabularyColorSchemeEnumMap = {
  VocabularyColorScheme.blue: 'blue',
  VocabularyColorScheme.green: 'green',
  VocabularyColorScheme.yellow: 'yellow',
  VocabularyColorScheme.orange: 'orange',
  VocabularyColorScheme.red: 'red',
  VocabularyColorScheme.purple: 'purple',
  VocabularyColorScheme.brown: 'brown',
  VocabularyColorScheme.white: 'white',
  VocabularyColorScheme.lightBlue: 'lightBlue',
  VocabularyColorScheme.pink: 'pink',
  VocabularyColorScheme.gray: 'gray',
};
