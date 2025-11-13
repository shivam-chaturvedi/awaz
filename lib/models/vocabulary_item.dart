import 'package:json_annotation/json_annotation.dart';

part 'vocabulary_item.g.dart';

@JsonSerializable()
class VocabularyItem {
  final String id;
  final String? imagePath; // Local path or asset path
  final String? imageUrl; // Network URL (optional)
  final Map<String, String> labels; // Language code -> word/phrase
  final String category;
  final String? parentId; // For nested categories
  final List<String> relatedWordIds; // Related words for learning
  final int tapCount; // Usage tracking
  final DateTime? lastUsed;
  final bool isFavorite;
  final VocabularyColorScheme colorScheme; // For color coding
  final int? gridPosition; // Position in grid
  final bool isFrozen; // For frozen row feature

  VocabularyItem({
    required this.id,
    this.imagePath,
    this.imageUrl,
    required this.labels,
    required this.category,
    this.parentId,
    this.relatedWordIds = const [],
    this.tapCount = 0,
    this.lastUsed,
    this.isFavorite = false,
    this.colorScheme = VocabularyColorScheme.blue,
    this.gridPosition,
    this.isFrozen = false,
  });

  String getLabel(String languageCode) {
    return labels[languageCode] ?? labels['en'] ?? '';
  }

  VocabularyItem copyWith({
    String? id,
    String? imagePath,
    String? imageUrl,
    Map<String, String>? labels,
    String? category,
    String? parentId,
    List<String>? relatedWordIds,
    int? tapCount,
    DateTime? lastUsed,
    bool? isFavorite,
    VocabularyColorScheme? colorScheme,
    int? gridPosition,
    bool? isFrozen,
  }) {
    return VocabularyItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      labels: labels ?? this.labels,
      category: category ?? this.category,
      parentId: parentId ?? this.parentId,
      relatedWordIds: relatedWordIds ?? this.relatedWordIds,
      tapCount: tapCount ?? this.tapCount,
      lastUsed: lastUsed ?? this.lastUsed,
      isFavorite: isFavorite ?? this.isFavorite,
      colorScheme: colorScheme ?? this.colorScheme,
      gridPosition: gridPosition ?? this.gridPosition,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) =>
      _$VocabularyItemFromJson(json);

  Map<String, dynamic> toJson() => _$VocabularyItemToJson(this);
}

enum VocabularyColorScheme {
  blue,
  green,
  yellow,
  orange,
  red,
  purple,
  brown,
  white,
  lightBlue,
  pink,
  gray,
}

