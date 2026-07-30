import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';

class VocabularyProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final TranslationService _translationService = TranslationService();
  List<VocabularyItem> _vocabularyItems = [];
  List<VocabularyItem> _recentWords = [];
  String? _currentCategory;
  bool _isLoading = false;
  List<String> _customGroups = [];

  static const List<String> builtInGroups = [
    'QUICK',
    'ACTIONS',
    'FEELINGS',
    'PEOPLE',
    'QUESTIONS',
    'TIME',
  ];

  static const List<String> _priorityLabels = [
    'Yes',
    'No',
    'Eating',
    'Running',
    'Hungry',
    'Mom',
    'Dad',
  ];

  List<String> get customGroups => List.unmodifiable(_customGroups);

  /// All groups: built-in + custom (deduped).
  List<String> get allGroups {
    final result = <String>[...builtInGroups];
    for (final g in _customGroups) {
      if (!result.contains(g)) result.add(g);
    }
    return result;
  }

  List<VocabularyItem> _applyPriorityOrder(List<VocabularyItem> items) {
    final prioritized = [...items];
    prioritized.sort((a, b) {
      final aIndex = _priorityIndex(a);
      final bIndex = _priorityIndex(b);
      if (aIndex != bIndex) return aIndex.compareTo(bIndex);
      final aLabel = _getLabelForSorting(a);
      final bLabel = _getLabelForSorting(b);
      return aLabel.compareTo(bLabel);
    });
    return prioritized;
  }

  int _priorityIndex(VocabularyItem item) {
    final label = _getLabelForSorting(item);
    final index = _priorityLabels.indexOf(label);
    return index == -1 ? _priorityLabels.length : index;
  }

  String _getLabelForSorting(VocabularyItem item) {
    return item.labels['en'] ?? item.labels.values.firstWhere((_) => true, orElse: () => '');
  }

  List<VocabularyItem> get vocabularyItems => _vocabularyItems;
  List<VocabularyItem> get recentWords => _recentWords;
  String? get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;

  Future<void> loadCustomGroups() async {
    try {
      _customGroups = await _storageService.getCustomGroups();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading custom groups: $e');
    }
  }

  Future<void> addCustomGroup(String name) async {
    final trimmed = name.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    if (_customGroups.contains(trimmed)) return;
    if (builtInGroups.contains(trimmed)) return;
    _customGroups = [..._customGroups, trimmed];
    await _storageService.saveCustomGroups(_customGroups);
    notifyListeners();
  }

  Future<void> removeCustomGroup(String name) async {
    _customGroups = _customGroups.where((g) => g != name).toList();
    await _storageService.saveCustomGroups(_customGroups);
    notifyListeners();
  }

  /// Returns all categories that actually have vocabulary items, merged with allGroups.
  Future<List<String>> getAllCategories() async {
    try {
      final items = await _storageService.getAllVocabularyItems();
      final fromItems = items.map((i) => i.category).toSet();
      // Keep allGroups order first, then extras at end
      final ordered = [...allGroups];
      for (final c in fromItems) {
        if (!ordered.contains(c)) ordered.add(c);
      }
      return ordered;
    } catch (e) {
      debugPrint('Error getting all categories: $e');
      return allGroups;
    }
  }

  Future<void> loadVocabularyItems({String? category}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (category != null && category != 'All') {
        _vocabularyItems = await _storageService.getVocabularyItemsByCategory(category);
        _currentCategory = category;
      } else {
        _vocabularyItems = await _storageService.getAllVocabularyItems();
        _currentCategory = category;
      }
      _vocabularyItems = _applyPriorityOrder(_vocabularyItems);
      
      // Update recent words (most recently used)
      _recentWords = _vocabularyItems
          .where((item) => item.lastUsed != null)
          .toList()
        ..sort((a, b) => b.lastUsed!.compareTo(a.lastUsed!));
    } catch (e) {
      debugPrint('Error loading vocabulary items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVocabularyItem(VocabularyItem item) async {
    try {
      await _storageService.saveVocabularyItem(item);
      await loadVocabularyItems(category: _currentCategory);
    } catch (e) {
      debugPrint('Error adding vocabulary item: $e');
    }
  }

  Future<void> updateVocabularyItem(VocabularyItem item) async {
    try {
      await _storageService.saveVocabularyItem(item);
      await loadVocabularyItems(category: _currentCategory);
    } catch (e) {
      debugPrint('Error updating vocabulary item: $e');
    }
  }

  Future<void> deleteVocabularyItem(String id) async {
    try {
      await _storageService.deleteVocabularyItem(id);
      await loadVocabularyItems(category: _currentCategory);
    } catch (e) {
      debugPrint('Error deleting vocabulary item: $e');
    }
  }

  Future<void> recordWordUsage(String id) async {
    try {
      final item = _vocabularyItems.firstWhere((item) => item.id == id);
      final updatedItem = item.copyWith(
        tapCount: item.tapCount + 1,
        lastUsed: DateTime.now(),
      );
      await _storageService.updateVocabularyItemTapCount(id, updatedItem.tapCount);
      await _storageService.saveVocabularyItem(updatedItem);
      
      // Reload to update recent words
      await loadVocabularyItems(category: _currentCategory);
    } catch (e) {
      debugPrint('Error recording word usage: $e');
    }
  }

  List<VocabularyItem> getFrozenRowItems() {
    return _vocabularyItems.where((item) => item.isFrozen).toList();
  }

  List<VocabularyItem> getFavoriteItems() {
    return _vocabularyItems.where((item) => item.isFavorite).toList();
  }

  List<String> getCategories() {
    return _vocabularyItems.map((item) => item.category).toSet().toList();
  }

  Future<void> translateAllVocabulary(String targetLanguage) async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _storageService.getAllVocabularyItems();
      for (var item in items) {
        final baseLabel = item.labels['en'] ?? item.labels.values.firstWhere((_) => true, orElse: () => '');
        if (baseLabel.isNotEmpty) {
          final translated = await _translationService.translate(
            text: baseLabel,
            targetLanguage: targetLanguage,
          );
          final newLabels = Map<String, String>.from(item.labels);
          newLabels[targetLanguage] = translated;
          await _storageService.saveVocabularyItem(item.copyWith(labels: newLabels));
        }
      }
      await loadVocabularyItems(category: _currentCategory);
    } catch (e) {
      debugPrint('Error translating vocabulary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
