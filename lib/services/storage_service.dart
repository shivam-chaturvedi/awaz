import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_item.dart';
import '../models/app_settings.dart';
import '../models/usage_log.dart';

// Import database libraries - these will be stubbed on web
import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:awaz/services/database_stub.dart';
import 'package:path/path.dart' if (dart.library.html) 'package:awaz/services/path_stub.dart';
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'package:awaz/services/path_provider_stub.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  dynamic _database; // Use dynamic to avoid type issues on web
  SharedPreferences? _prefs;
  bool get _isWeb => kIsWeb;
  bool _useDatabase = false;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_isWeb) {
      try {
        await _initDatabase();
        _useDatabase = true;
      } catch (e) {
        debugPrint('Database initialization failed, using SharedPreferences: $e');
        _useDatabase = false;
      }
    }
  }

  Future<void> _initDatabase() async {
    if (_isWeb) return;
    
    try {
      // These will only compile on non-web platforms
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(documentsDirectory.path, 'awaz_database.db');

      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          if (_isWeb) return; // Skip on web
          // Vocabulary items table
          await db.execute('''
            CREATE TABLE vocabulary_items (
              id TEXT PRIMARY KEY,
              image_path TEXT,
              image_url TEXT,
              labels TEXT,
              category TEXT,
              parent_id TEXT,
              related_word_ids TEXT,
              tap_count INTEGER,
              last_used TEXT,
              is_favorite INTEGER,
              color_scheme TEXT,
              grid_position INTEGER,
              is_frozen INTEGER
            )
          ''');

          // Usage logs table
          await db.execute('''
            CREATE TABLE usage_logs (
              id TEXT PRIMARY KEY,
              vocabulary_item_id TEXT,
              timestamp TEXT,
              language_code TEXT,
              sentence TEXT,
              session_duration INTEGER,
              FOREIGN KEY (vocabulary_item_id) REFERENCES vocabulary_items (id)
            )
          ''');

          // Create indexes
          await db.execute('CREATE INDEX idx_category ON vocabulary_items(category)');
          await db.execute('CREATE INDEX idx_timestamp ON usage_logs(timestamp)');
        },
      );
    } catch (e) {
      debugPrint('Database error: $e');
      rethrow;
    }
  }

  // Vocabulary Items
  Future<void> saveVocabularyItem(VocabularyItem item) async {
    if (_isWeb || !_useDatabase) {
      await _saveVocabularyItemWeb(item);
    } else {
      await _saveVocabularyItemMobile(item);
    }
  }

  Future<void> _saveVocabularyItemWeb(VocabularyItem item) async {
    if (_prefs == null) await initialize();
    
    final items = await getAllVocabularyItems();
    final index = items.indexWhere((i) => i.id == item.id);
    
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    
    final itemsJson = items.map((i) => i.toJson()).toList();
    await _prefs!.setString('vocabulary_items', jsonEncode(itemsJson));
  }

  Future<void> _saveVocabularyItemMobile(VocabularyItem item) async {
    if (_database == null) await initialize();
    if (_database == null) {
      await _saveVocabularyItemWeb(item);
      return;
    }
    
    try {
      await _database.insert(
        'vocabulary_items',
        {
          'id': item.id,
          'image_path': item.imagePath,
          'image_url': item.imageUrl,
          'labels': jsonEncode(item.labels),
          'category': item.category,
          'parent_id': item.parentId,
          'related_word_ids': jsonEncode(item.relatedWordIds),
          'tap_count': item.tapCount,
          'last_used': item.lastUsed?.toIso8601String(),
          'is_favorite': item.isFavorite ? 1 : 0,
          'color_scheme': item.colorScheme.toString().split('.').last,
          'grid_position': item.gridPosition,
          'is_frozen': item.isFrozen ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Database insert failed, falling back to SharedPreferences: $e');
      await _saveVocabularyItemWeb(item);
    }
  }

  Future<List<VocabularyItem>> getAllVocabularyItems() async {
    if (_isWeb || !_useDatabase) {
      return await _getAllVocabularyItemsWeb();
    } else {
      return await _getAllVocabularyItemsMobile();
    }
  }

  Future<List<VocabularyItem>> _getAllVocabularyItemsWeb() async {
    if (_prefs == null) await initialize();
    
    final itemsJson = _prefs!.getString('vocabulary_items');
    if (itemsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(itemsJson);
    return decoded.map((json) => VocabularyItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<VocabularyItem>> _getAllVocabularyItemsMobile() async {
    if (_database == null) await initialize();
    if (_database == null) {
      return await _getAllVocabularyItemsWeb();
    }
    
    final List<Map<String, dynamic>> maps = await _database.query('vocabulary_items');
    return maps.map((map) => _mapToVocabularyItem(map)).toList();
  }

  Future<List<VocabularyItem>> getVocabularyItemsByCategory(String category) async {
    final allItems = await getAllVocabularyItems();
    return allItems.where((item) => item.category == category).toList();
  }

  Future<VocabularyItem?> getVocabularyItem(String id) async {
    final allItems = await getAllVocabularyItems();
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteVocabularyItem(String id) async {
    if (_isWeb || !_useDatabase) {
      await _deleteVocabularyItemWeb(id);
    } else {
      await _deleteVocabularyItemMobile(id);
    }
  }

  Future<void> _deleteVocabularyItemWeb(String id) async {
    final items = await getAllVocabularyItems();
    items.removeWhere((item) => item.id == id);
    final itemsJson = items.map((i) => i.toJson()).toList();
    await _prefs!.setString('vocabulary_items', jsonEncode(itemsJson));
  }

  Future<void> _deleteVocabularyItemMobile(String id) async {
    if (_database == null) await initialize();
    if (_database == null) {
      await _deleteVocabularyItemWeb(id);
      return;
    }
    await _database.delete('vocabulary_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateVocabularyItemTapCount(String id, int count) async {
    final item = await getVocabularyItem(id);
    if (item != null) {
      final updated = item.copyWith(
        tapCount: count,
        lastUsed: DateTime.now(),
      );
      await saveVocabularyItem(updated);
    }
  }

  VocabularyItem _mapToVocabularyItem(Map<String, dynamic> map) {
    return VocabularyItem(
      id: map['id'] as String,
      imagePath: map['image_path'] as String?,
      imageUrl: map['image_url'] as String?,
      labels: Map<String, String>.from(jsonDecode(map['labels'] as String)),
      category: map['category'] as String,
      parentId: map['parent_id'] as String?,
      relatedWordIds: List<String>.from(jsonDecode(map['related_word_ids'] as String)),
      tapCount: map['tap_count'] as int,
      lastUsed: map['last_used'] != null ? DateTime.parse(map['last_used'] as String) : null,
      isFavorite: (map['is_favorite'] as int) == 1,
      colorScheme: VocabularyColorScheme.values.firstWhere(
        (e) => e.toString().split('.').last == map['color_scheme'],
        orElse: () => VocabularyColorScheme.blue,
      ),
      gridPosition: map['grid_position'] as int?,
      isFrozen: (map['is_frozen'] as int) == 1,
    );
  }

  // Usage Logs
  Future<void> saveUsageLog(UsageLog log) async {
    if (_isWeb || !_useDatabase) {
      await _saveUsageLogWeb(log);
    } else {
      await _saveUsageLogMobile(log);
    }
  }

  Future<void> _saveUsageLogWeb(UsageLog log) async {
    if (_prefs == null) await initialize();
    
    final logs = await getUsageLogs();
    logs.add(log);
    
    // Keep only last 1000 logs to avoid storage issues
    if (logs.length > 1000) {
      logs.removeRange(0, logs.length - 1000);
    }
    
    final logsJson = logs.map((l) => l.toJson()).toList();
    await _prefs!.setString('usage_logs', jsonEncode(logsJson));
  }

  Future<void> _saveUsageLogMobile(UsageLog log) async {
    if (_database == null) await initialize();
    if (_database == null) {
      await _saveUsageLogWeb(log);
      return;
    }
    
    await _database.insert(
      'usage_logs',
      {
        'id': log.id,
        'vocabulary_item_id': log.vocabularyItemId,
        'timestamp': log.timestamp.toIso8601String(),
        'language_code': log.languageCode,
        'sentence': log.sentence,
        'session_duration': log.sessionDuration?.inMicroseconds,
      },
    );
  }

  Future<List<UsageLog>> getUsageLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? vocabularyItemId,
  }) async {
    if (_isWeb || !_useDatabase) {
      return await _getUsageLogsWeb(startDate: startDate, endDate: endDate, vocabularyItemId: vocabularyItemId);
    } else {
      return await _getUsageLogsMobile(startDate: startDate, endDate: endDate, vocabularyItemId: vocabularyItemId);
    }
  }

  Future<List<UsageLog>> _getUsageLogsWeb({
    DateTime? startDate,
    DateTime? endDate,
    String? vocabularyItemId,
  }) async {
    if (_prefs == null) await initialize();
    
    final logsJson = _prefs!.getString('usage_logs');
    if (logsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(logsJson);
    var logs = decoded.map((json) => UsageLog.fromJson(json as Map<String, dynamic>)).toList();
    
    // Apply filters
    if (startDate != null && endDate != null) {
      logs = logs.where((log) => 
        log.timestamp.isAfter(startDate) && log.timestamp.isBefore(endDate)
      ).toList();
    }
    
    if (vocabularyItemId != null) {
      logs = logs.where((log) => log.vocabularyItemId == vocabularyItemId).toList();
    }
    
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  Future<List<UsageLog>> _getUsageLogsMobile({
    DateTime? startDate,
    DateTime? endDate,
    String? vocabularyItemId,
  }) async {
    if (_database == null) await initialize();
    if (_database == null) {
      return await _getUsageLogsWeb(startDate: startDate, endDate: endDate, vocabularyItemId: vocabularyItemId);
    }
    
    String? where;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'timestamp BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (vocabularyItemId != null) {
      where = 'vocabulary_item_id = ?';
      whereArgs = [vocabularyItemId];
    }

    final List<Map<String, dynamic>> maps = await _database.query(
      'usage_logs',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => UsageLog(
      id: map['id'] as String,
      vocabularyItemId: map['vocabulary_item_id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      languageCode: map['language_code'] as String,
      sentence: map['sentence'] as String?,
      sessionDuration: map['session_duration'] != null
          ? Duration(microseconds: map['session_duration'] as int)
          : null,
    )).toList();
  }

  // App Settings
  Future<void> saveSettings(AppSettings settings) async {
    if (_prefs == null) await initialize();
    await _prefs!.setString('app_settings', jsonEncode(settings.toJson()));
  }

  Future<AppSettings> getSettings() async {
    if (_prefs == null) await initialize();
    final settingsJson = _prefs!.getString('app_settings');
    if (settingsJson == null) {
      return AppSettings();
    }
    return AppSettings.fromJson(jsonDecode(settingsJson));
  }

  // Export/Backup
  Future<Map<String, dynamic>> exportAllData() async {
    final vocabularyItems = await getAllVocabularyItems();
    final usageLogs = await getUsageLogs();
    final settings = await getSettings();

    return {
      'vocabulary_items': vocabularyItems.map((item) => item.toJson()).toList(),
      'usage_logs': usageLogs.map((log) => log.toJson()).toList(),
      'settings': settings.toJson(),
      'export_date': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Import vocabulary items
    if (data['vocabulary_items'] != null) {
      for (var itemJson in data['vocabulary_items'] as List) {
        final item = VocabularyItem.fromJson(itemJson as Map<String, dynamic>);
        await saveVocabularyItem(item);
      }
    }

    // Import usage logs
    if (data['usage_logs'] != null) {
      for (var logJson in data['usage_logs'] as List) {
        final log = UsageLog.fromJson(logJson as Map<String, dynamic>);
        await saveUsageLog(log);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      final settings = AppSettings.fromJson(data['settings'] as Map<String, dynamic>);
      await saveSettings(settings);
    }
  }
}
