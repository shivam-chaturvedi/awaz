import '../models/vocabulary_item.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class VocabularyInitializer {
  static final Uuid _uuid = const Uuid();
  static final StorageService _storageService = StorageService();

  static Future<void> initializeDefaultVocabulary() async {
    final existing = await _storageService.getAllVocabularyItems();
    if (existing.isNotEmpty) return;

    final defaultItems = _createDefaultVocabulary();
    for (var item in defaultItems) {
      await _storageService.saveVocabularyItem(item);
    }
  }

  static List<VocabularyItem> _createDefaultVocabulary() {
    return [
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Yes'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.green,
        isFrozen: true,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'No'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.red,
        isFrozen: true,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Hello'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Thank you'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Please'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'What'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Where'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'When'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Why'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'How'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'I'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'You'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Mom'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.pink,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Dad'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Eat'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.orange,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Drink'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Play'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Sleep'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Go'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.red,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Happy'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Sad'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Angry'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.red,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Tired'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.gray,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Now'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Later'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Today'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Tomorrow'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
    ];
  }
}
