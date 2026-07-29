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
    bool clearImagePath = false,
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
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
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

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    final labelsMap = json['labels'] as Map<String, dynamic>? ?? {};
    final relatedIds = (json['relatedWordIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

    return VocabularyItem(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      labels: labelsMap.map((key, value) => MapEntry(key, value as String)),
      category: json['category'] as String,
      parentId: json['parentId'] as String?,
      relatedWordIds: relatedIds,
      tapCount: json['tapCount'] as int? ?? 0,
      lastUsed: json['lastUsed'] != null ? DateTime.tryParse(json['lastUsed'] as String) : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      colorScheme: _colorSchemeFromString(json['colorScheme'] as String?) ?? VocabularyColorScheme.blue,
      gridPosition: json['gridPosition'] as int?,
      isFrozen: json['isFrozen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'labels': labels,
      'category': category,
      'parentId': parentId,
      'relatedWordIds': relatedWordIds,
      'tapCount': tapCount,
      'lastUsed': lastUsed?.toIso8601String(),
      'isFavorite': isFavorite,
      'colorScheme': colorScheme.name,
      'gridPosition': gridPosition,
      'isFrozen': isFrozen,
    };
  }
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

VocabularyColorScheme? _colorSchemeFromString(String? value) {
  if (value == null || value.isEmpty) return null;
  return VocabularyColorScheme.values.firstWhere(
    (scheme) => scheme.name == value,
    orElse: () => VocabularyColorScheme.blue,
  );
}
