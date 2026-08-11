import '../models/vocabulary_item.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class VocabularyInitializer {
  static final Uuid _uuid = const Uuid();
  static final StorageService _storageService = StorageService();

  static Future<void> initializeDefaultVocabulary() async {
    final existing = await _storageService.getAllVocabularyItems();
    if (existing.isNotEmpty) {
      await _ensureDefaults(existing);
      return;
    }

    final defaultItems = _createDefaultVocabulary();
    for (var item in defaultItems) {
      await _storageService.saveVocabularyItem(item);
    }
  }

  // ignore: unused_field
  static const Map<String, String> _defaultImagePaths = {
    'Yes': 'assets/images/Yes.jpg',
    'No': 'assets/images/No.jpg',
    'Hello': 'assets/images/Hello.jpg',
    'Thank you': 'assets/images/Thank_you.jpg',
    'Please': 'assets/images/Please.jpg',
    'What': 'assets/images/What.jpg',
    'Where': 'assets/images/Where.jpg',
    'When': 'assets/images/When.jpg',
    'Why': 'assets/images/Why.jpg',
    'How': 'assets/images/How.jpg',
    'I': 'assets/images/I.jpg',
    'You': 'assets/images/You.jpg',
    'Eat': 'assets/images/Eat.jpg',
    'Drink': 'assets/images/Drink.jpg',
    'Play': 'assets/images/Play.jpg',
    'Sleep': 'assets/images/Sleep.jpg',
    'Go': 'assets/images/Go.jpg',
    'Happy': 'assets/images/Happy.jpg',
    'Sad': 'assets/images/Sad.jpg',
    'Angry': 'assets/images/Angry.jpg',
    'Tired': 'assets/images/Tired.jpg',
    'Now': 'assets/images/Now.jpg',
    'Later': 'assets/images/Later.jpg',
    'Today': 'assets/images/Today.jpg',
    'Tomorrow': 'assets/images/Tomorrow.jpg',
  };

  static Future<void> _ensureDefaults(List<VocabularyItem> existing) async {
    final existingByLabel = <String, VocabularyItem>{};
    for (final item in existing) {
      final fallbackLabel = item.labels.isNotEmpty ? item.labels.values.first : '';
      final labelKey = item.labels['en'] ?? fallbackLabel;
      if (labelKey.isEmpty) continue;
      existingByLabel[labelKey] = item;
    }

    final defaults = _createDefaultVocabulary();
    for (final defaultItem in defaults) {
      final label = defaultItem.labels['en'] ?? '';
      final existingItem = existingByLabel[label];
      if (existingItem == null) {
        await _storageService.saveVocabularyItem(defaultItem);
        continue;
      }

      if (existingItem.colorScheme != defaultItem.colorScheme || 
          existingItem.imagePath != defaultItem.imagePath) {
        await _storageService.saveVocabularyItem(existingItem.copyWith(
          colorScheme: defaultItem.colorScheme,
          imagePath: defaultItem.imagePath,
        ));
      }
    }
  }

  static List<VocabularyItem> _createDefaultVocabulary() {
    return [
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Yes'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.red,
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
        colorScheme: VocabularyColorScheme.red,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Thank you'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.red,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Please'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.red,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'What'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Where'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'When'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Why'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'How'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'I'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'You'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Mom'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Dad'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Eat'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Eating'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Running'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
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
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Sleep'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Go'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Happy'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Hungry'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Sad'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Angry'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Tired'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Now'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.pink,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Later'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.pink,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Today'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.pink,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Tomorrow'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.pink,
      ),
    ];
  }
}
