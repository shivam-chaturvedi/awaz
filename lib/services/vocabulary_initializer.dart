import '../models/vocabulary_item.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class VocabularyInitializer {
  static final Uuid _uuid = const Uuid();
  static final StorageService _storageService = StorageService();

  static Future<void> initializeDefaultVocabulary() async {
    // Check if vocabulary already exists
    final existing = await _storageService.getAllVocabularyItems();
    if (existing.isNotEmpty) {
      return; // Already initialized
    }

    // Create default vocabulary items
    final defaultItems = _createDefaultVocabulary();
    
    for (var item in defaultItems) {
      await _storageService.saveVocabularyItem(item);
    }
  }

  static List<VocabularyItem> _createDefaultVocabulary() {
    return [
      // Quick words
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Yes', 'hi': 'हाँ', 'ta': 'ஆம்'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.green,
        isFrozen: true,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'No', 'hi': 'नहीं', 'ta': 'இல்லை'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.red,
        isFrozen: true,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Hello', 'hi': 'नमस्ते', 'ta': 'வணக்கம்'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Thank you', 'hi': 'धन्यवाद', 'ta': 'நன்றி'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Please', 'hi': 'कृपया', 'ta': 'தயவுசெய்து'},
        category: 'QUICK',
        colorScheme: VocabularyColorScheme.blue,
      ),
      
      // Questions
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'What', 'hi': 'क्या', 'ta': 'என்ன'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Where', 'hi': 'कहाँ', 'ta': 'எங்கே'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'When', 'hi': 'कब', 'ta': 'எப்போது'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Why', 'hi': 'क्यों', 'ta': 'ஏன்'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'How', 'hi': 'कैसे', 'ta': 'எப்படி'},
        category: 'QUESTIONS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      
      // People
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'I', 'hi': 'मैं', 'ta': 'நான்'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'You', 'hi': 'तुम', 'ta': 'நீங்கள்'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Mom', 'hi': 'माँ', 'ta': 'அம்மா'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.pink,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Dad', 'hi': 'पापा', 'ta': 'அப்பா'},
        category: 'PEOPLE',
        colorScheme: VocabularyColorScheme.blue,
      ),
      
      // Actions
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Eat', 'hi': 'खाना', 'ta': 'சாப்பிட'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.orange,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Drink', 'hi': 'पीना', 'ta': 'குடி'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Play', 'hi': 'खेलना', 'ta': 'விளையாட'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.green,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Sleep', 'hi': 'सोना', 'ta': 'தூங்க'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.purple,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Go', 'hi': 'जाना', 'ta': 'போ'},
        category: 'ACTIONS',
        colorScheme: VocabularyColorScheme.red,
      ),
      
      // Feelings
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Happy', 'hi': 'खुश', 'ta': 'மகிழ்ச்சி'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.yellow,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Sad', 'hi': 'उदास', 'ta': 'வருத்தம்'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.blue,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Angry', 'hi': 'गुस्सा', 'ta': 'கோபம்'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.red,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Tired', 'hi': 'थका हुआ', 'ta': 'சோர்வு'},
        category: 'FEELINGS',
        colorScheme: VocabularyColorScheme.gray,
      ),
      
      // Time
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Now', 'hi': 'अभी', 'ta': 'இப்போது'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Later', 'hi': 'बाद में', 'ta': 'பின்னர்'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Today', 'hi': 'आज', 'ta': 'இன்று'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
      VocabularyItem(
        id: _uuid.v4(),
        labels: {'en': 'Tomorrow', 'hi': 'कल', 'ta': 'நாளை'},
        category: 'TIME',
        colorScheme: VocabularyColorScheme.brown,
      ),
    ];
  }
}

