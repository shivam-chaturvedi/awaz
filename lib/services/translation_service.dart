import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Map<String, OnDeviceTranslator> _translators = {};
  final Map<String, String> _translationCache = {};

  static const Map<String, Map<String, String>> _builtInTranslations = {
    'hi': {
      'All': 'सभी',
      'QUICK': 'त्वरित',
      'ACTIONS': 'क्रियाएं',
      'FEELINGS': 'भावनाएं',
      'PEOPLE': 'लोग',
      'QUESTIONS': 'प्रश्न',
      'TIME': 'समय',
      'PLACES': 'स्थान',
      'FOOD': 'भोजन',
      'ANIMALS': 'जानवर',
      'CLOTHES': 'कपड़े',
      'BODY PARTS': 'शरीर के अंग',
      'Tap words to build a sentence...': 'वाक्य बनाने के लिए शब्दों पर टैप करें...',
      'Back to groups': 'समूहों पर वापस जाएं',
      'No words in this category yet': 'इस श्रेणी में अभी कोई शब्द नहीं हैं',
      'Add items from the Caregiver Dashboard': 'देखभालकर्ता डैशबोर्ड से आइटम जोड़ें',
      'Added: ': 'जोड़ा गया: ',
      'Yes': 'हाँ',
      'No': 'नहीं',
      'Hello': 'नमस्ते',
      'Thank you': 'धन्यवाद',
      'Please': 'कृपया',
      'What': 'क्या',
      'Where': 'कहाँ',
      'When': 'कब',
      'Why': 'क्यों',
      'How': 'कैसे',
      'I': 'मैं',
      'You': 'आप',
      'Mom': 'माँ',
      'Dad': 'पापा',
      'Eat': 'खाओ',
      'Eating': 'खा रहा है',
      'Running': 'दौड़ रहा है',
      'Drink': 'पिओ',
      'Play': 'खेलें',
      'Sleep': 'सो जाओ',
      'Go': 'जाओ',
      'Happy': 'खुश',
      'Hungry': 'भूखा',
      'Sad': 'उदासीन',
      'Angry': 'गुस्सा',
      'Tired': 'थका हुआ',
      'Now': 'अब',
      'Later': 'बाद में',
      'Today': 'आज',
      'Tomorrow': 'कल',
    },
    'ta': {
      'All': 'எல்லாம்',
      'QUICK': 'விரைவு',
      'ACTIONS': 'செயல்கள்',
      'FEELINGS': 'உணர்வுகள்',
      'PEOPLE': 'நபர்கள்',
      'QUESTIONS': 'கேள்விகள்',
      'TIME': 'நேரம்',
      'PLACES': 'இடங்கள்',
      'FOOD': 'உணவு',
      'ANIMALS': 'விலங்குகள்',
      'CLOTHES': 'ஆடைகள்',
      'BODY PARTS': 'உடல் உறுப்புகள்',
      'Tap words to build a sentence...': 'சொற்றொடரை உருவாக்க சொற்களைத் தட்டவும்...',
      'Back to groups': 'குழுக்களுக்குத் திரும்பு',
      'No words in this category yet': 'இந்த பிரிவில் இதுவரை சொற்கள் இல்லை',
      'Add items from the Caregiver Dashboard': 'பராமரிப்பாளர் டாஷ்போர்டில் இருந்து சேர்க்கவும்',
      'Added: ': 'சேர்க்கப்பட்டது: ',
      'Yes': 'ஆம்',
      'No': 'இல்லை',
      'Hello': 'வணக்கம்',
      'Thank you': 'நன்றி',
      'Please': 'தயவுசெய்து',
      'What': 'என்ன',
      'Where': 'எங்கே',
      'When': 'எப்போது',
      'Why': 'ஏன்',
      'How': 'எப்படி',
      'I': 'நான்',
      'You': 'நீங்கள்',
      'Mom': 'அம்மா',
      'Dad': 'அப்பா',
      'Eat': 'சாப்பிடு',
      'Eating': 'சாப்பிடுகிறது',
      'Running': 'ஓடுகிறது',
      'Drink': 'குடி',
      'Play': 'விளையாடு',
      'Sleep': 'தூங்கு',
      'Go': 'போ',
      'Happy': 'மகிழ்ச்சி',
      'Hungry': 'பசி',
      'Sad': 'வருத்தம்',
      'Angry': 'கோபம்',
      'Tired': 'சோர்வு',
      'Now': 'இப்போது',
      'Later': 'பின்னர்',
      'Today': 'இன்று',
      'Tomorrow': 'நாளை',
    },
    'te': {
      'All': 'అన్నీ',
      'QUICK': 'త్వరిత',
      'ACTIONS': 'చర్యలు',
      'FEELINGS': 'భావాలు',
      'PEOPLE': 'ప్రజలు',
      'QUESTIONS': 'ప్రశ్నలు',
      'TIME': 'సమయం',
      'PLACES': 'ప్రాంతాలు',
      'FOOD': 'ఆహారం',
      'ANIMALS': 'జంతువులు',
      'CLOTHES': 'బట్టలు',
      'BODY PARTS': 'శరీర భాగాలు',
      'Tap words to build a sentence...': 'వాక్యాన్ని నిర్మించడానికి పదాలను నొక్కండి...',
      'Back to groups': 'సమూహాలకు తిరిగి వెళ్ళు',
      'No words in this category yet': 'ఈ వర్గంలో ఇంకా పదాలు లేవు',
      'Add items from the Caregiver Dashboard': 'సంరక్షకుల డాష్‌బోర్డ్ నుండి అంశాలను జోడించండి',
      'Added: ': 'జోడించబడింది: ',
      'Yes': 'అవును',
      'No': 'కాదు',
      'Hello': 'నమస్కారం',
      'Thank you': 'ధన్యవాదాలు',
      'Please': 'దయచేసి',
      'What': 'ఏమిటి',
      'Where': 'ఎక్కడ',
      'When': 'ఎప్పుడు',
      'Why': 'ఎందుకు',
      'How': 'ఎలా',
      'I': 'నేను',
      'You': 'మీరు',
      'Mom': 'అమ్మ',
      'Dad': 'నాన్న',
      'Eat': 'తినండి',
      'Eating': 'తింటున్నాడు',
      'Running': 'పరుగెత్తుతున్నాడు',
      'Drink': 'తాగండి',
      'Play': 'ఆడు',
      'Sleep': 'నిద్రపో',
      'Go': 'వెళ్ళు',
      'Happy': 'సంతోషం',
      'Hungry': 'ఆకలి',
      'Sad': 'బాధగా',
      'Angry': 'కోపం',
      'Tired': 'అలసిపోయిన',
      'Now': 'ఇప్పుడు',
      'Later': 'తర్వాత',
      'Today': 'ఈ రోజు',
      'Tomorrow': 'రేపు',
    },
    'kn': {
      'All': 'ಎಲ್ಲವೂ',
      'QUICK': 'ತ್ವರಿತ',
      'ACTIONS': 'ಕ್ರಿಯೆಗಳು',
      'FEELINGS': 'ಭಾವನೆಗಳು',
      'PEOPLE': 'ಜನರು',
      'QUESTIONS': 'ಪ್ರಶ್ನೆಗಳು',
      'TIME': 'ಸಮಯ',
      'PLACES': 'ಸ್ಥಳಗಳು',
      'FOOD': 'ಆಹಾರ',
      'ANIMALS': 'ಪ್ರಾಣಿಗಳು',
      'CLOTHES': 'ಉಡುಪುಗಳು',
      'BODY PARTS': 'ದೇಹದ ಅಂಗಗಳು',
      'Tap words to build a sentence...': 'ವಾಕ್ಯವನ್ನು ನಿರ್ಮಿಸಲು ಪದಗಳನ್ನು ತಟ್ಟಿ...',
      'Back to groups': 'ಗುಂಪುಗಳಿಗೆ ಹಿಂತಿರುಗಿ',
      'No words in this category yet': 'ಈ ವರ್ಗದಲ್ಲಿ ಇನ್ನೂ ಯಾವುದೇ ಪದಗಳಿಲ್ಲ',
      'Add items from the Caregiver Dashboard': 'ಆರೈಕೆದಾರರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಿಂದ ಅಂಶಗಳನ್ನು ಸೇರಿಸಿ',
      'Added: ': 'ಸೇರಿಸಲಾಗಿದೆ: ',
      'Yes': 'ಹೌದು',
      'No': 'ಇಲ್ಲ',
      'Hello': 'ನಮಸ್ಕಾರ',
      'Thank you': 'ಧನ್ಯವಾದಗಳು',
      'Please': 'ದಯವಿಟ್ಟು',
      'What': 'ಏನು',
      'Where': 'ಎಲ್ಲಿ',
      'When': 'ಯಾವಾಗ',
      'Why': 'ಏಕೆ',
      'How': 'ಹೇಗೆ',
      'I': 'ನಾನು',
      'You': 'ನೀವು',
      'Mom': 'ಅಮ್ಮ',
      'Dad': 'ಅಪ್ಪ',
      'Eat': 'ತಿನ್ನು',
      'Eating': 'ತಿನ್ನುತ್ತಿದ್ದಾನೆ',
      'Running': 'ಓಡುತ್ತಿದ್ದಾನೆ',
      'Drink': 'ಕುಡಿ',
      'Play': 'ಆಡು',
      'Sleep': 'ಮಲಗು',
      'Go': 'ಹೋಗು',
      'Happy': 'ಸಂತೋಷ',
      'Hungry': 'ಹಸಿವು',
      'Sad': 'ದುಃಖ',
      'Angry': 'ಕೋಪ',
      'Tired': 'ಆಯಾಸ',
      'Now': 'ಈಗ',
      'Later': 'ನಂತರ',
      'Today': 'ಇಂದು',
      'Tomorrow': 'ನಾಳೆ',
    },
    'ml': {
      'All': 'എല്ലാം',
      'QUICK': 'വേഗത്തിൽ',
      'ACTIONS': 'പ്രവർത്തികൾ',
      'FEELINGS': 'വികാരങ്ങൾ',
      'PEOPLE': 'ആളുകൾ',
      'QUESTIONS': 'ചോദ്യങ്ങൾ',
      'TIME': 'സമയം',
      'PLACES': 'സ്ഥലങ്ങൾ',
      'FOOD': 'ഭക്ഷണം',
      'ANIMALS': 'മൃഗങ്ങൾ',
      'CLOTHES': 'വസ്ത്രങ്ങൾ',
      'BODY PARTS': 'ശരീരഭാഗങ്ങൾ',
      'Tap words to build a sentence...': 'വാചകം നിർമ്മിക്കാൻ വാക്കുകൾ തട്ടുക...',
      'Back to groups': 'ഗ്രൂപ്പുകളിലേക്ക് മടങ്ങുക',
      'No words in this category yet': 'ഈ വിഭാഗത്തിൽ ഇതുവരെ വാക്കുകളൊന്നുമില്ല',
      'Add items from the Caregiver Dashboard': 'കെയർഗിവർ ഡാഷ്‌ബോർഡിൽ നിന്ന് ചേർക്കുക',
      'Added: ': 'ചേർത്തു: ',
      'Yes': 'അതെ',
      'No': 'ഇല്ല',
      'Hello': 'ഹലോ',
      'Thank you': 'നന്ദി',
      'Please': 'ദയവായി',
      'What': 'എന്ത്',
      'Where': 'എവിടെ',
      'When': 'എപ്പോൾ',
      'Why': 'എന്തുകൊണ്ട്',
      'How': 'എങ്ങനെ',
      'I': 'ഞാൻ',
      'You': 'നിങ്ങൾ',
      'Mom': 'അമ്മ',
      'Dad': 'അച്ഛൻ',
      'Eat': 'കഴിക്കുക',
      'Eating': 'കഴിക്കുന്നു',
      'Running': 'ഓടുന്നു',
      'Drink': 'കുടിക്കുക',
      'Play': 'കളിക്കുക',
      'Sleep': 'ഉറങ്ങുക',
      'Go': 'പോവുക',
      'Happy': 'സന്തോഷം',
      'Hungry': 'വിശപ്പ്',
      'Sad': 'വിഷമം',
      'Angry': 'ദേഷ്യം',
      'Tired': 'ക്ഷീണം',
      'Now': 'ഇപ്പോൾ',
      'Later': 'പിന്നീട്',
      'Today': 'ഇന്ന്',
      'Tomorrow': 'നാളെ',
    },
    'mr': {
      'All': 'सर्व',
      'QUICK': 'जलद',
      'ACTIONS': 'कृती',
      'FEELINGS': 'भावना',
      'PEOPLE': 'लोक',
      'QUESTIONS': 'प्रश्न',
      'TIME': 'वेळ',
      'PLACES': 'ठिकाणे',
      'FOOD': 'अन्न',
      'ANIMALS': 'प्राणी',
      'CLOTHES': 'कपडे',
      'BODY PARTS': 'शरीराचे भाग',
      'Tap words to build a sentence...': 'वाक्य बनवण्यासाठी शब्दांवर टॅप करा...',
      'Back to groups': 'गटांवर परत जा',
      'No words in this category yet': 'या श्रेणीत अद्याप कोणतेही शब्द नाहीत',
      'Add items from the Caregiver Dashboard': 'केअरगिव्हर डॅशबोर्डवरून आयटम जोडा',
      'Added: ': 'जोडले: ',
      'Yes': 'होय',
      'No': 'नाही',
      'Hello': 'नमस्कार',
      'Thank you': 'धन्यवाद',
      'Please': 'कृपया',
      'What': 'काय',
      'Where': 'कुठे',
      'When': 'केव्हा',
      'Why': 'का',
      'How': 'कसे',
      'I': 'मी',
      'You': 'तुम्ही',
      'Mom': 'आई',
      'Dad': 'बाबा',
      'Eat': 'खा',
      'Eating': 'खात आहे',
      'Running': 'पळत आहे',
      'Drink': 'प्या',
      'Play': 'खेळा',
      'Sleep': 'झोपा',
      'Go': 'जा',
      'Happy': 'आनंदी',
      'Hungry': 'भुकेलेला',
      'Sad': 'दुःखी',
      'Angry': 'रागावलेला',
      'Tired': 'थकलेला',
      'Now': 'आता',
      'Later': 'नंतर',
      'Today': 'आज',
      'Tomorrow': 'उद्या',
    },
    'bn': {
      'All': 'সব',
      'QUICK': 'দ্রুত',
      'ACTIONS': 'কাজ',
      'FEELINGS': 'অনুভূতি',
      'PEOPLE': 'মানুষ',
      'QUESTIONS': 'প্রশ্ন',
      'TIME': 'সময়',
      'PLACES': 'স্থান',
      'FOOD': 'খাবার',
      'ANIMALS': 'প্রাণী',
      'CLOTHES': 'পোশাক',
      'BODY PARTS': 'শরীরের অঙ্গ',
      'Tap words to build a sentence...': 'একটি বাক্য তৈরি করতে শব্দ স্পর্শ করুন...',
      'Back to groups': 'গ্রুপে ফিরে যান',
      'No words in this category yet': 'এই বিভাগে এখনও কোনো শব্দ নেই',
      'Add items from the Caregiver Dashboard': 'কেয়ারগিভার ড্যাশবোর্ড থেকে উপাদান যোগ করুন',
      'Added: ': 'যোগ করা হয়েছে: ',
      'Yes': 'হ্যাঁ',
      'No': 'না',
      'Hello': 'হ্যালো',
      'Thank you': 'ধন্যবাদ',
      'Please': 'দয়া করে',
      'What': 'কী',
      'Where': 'কোথায়',
      'When': 'কখন',
      'Why': 'কেন',
      'How': 'কীভাবে',
      'I': 'আমি',
      'You': 'আপনি',
      'Mom': 'মা',
      'Dad': 'বাবা',
      'Eat': 'খাওয়া',
      'Eating': 'খাচ্ছে',
      'Running': 'দৌড়াচ্ছে',
      'Drink': 'পান করা',
      'Play': 'খেলা',
      'Sleep': 'ঘুমানো',
      'Go': 'যাওয়া',
      'Happy': 'খুশি',
      'Hungry': 'ক্ষুধার্ত',
      'Sad': 'দুঃখিত',
      'Angry': 'রাগান্বিত',
      'Tired': 'ক্লান্ত',
      'Now': 'এখন',
      'Later': 'পরে',
      'Today': 'আজ',
      'Tomorrow': 'আগামীকাল',
    },
    'gu': {
      'All': 'બધા',
      'QUICK': 'ઝડપી',
      'ACTIONS': 'ક્રિયાઓ',
      'FEELINGS': 'લાગણીઓ',
      'PEOPLE': 'લોકો',
      'QUESTIONS': 'પ્રશ્નો',
      'TIME': 'સમય',
      'PLACES': 'જગ્યાઓ',
      'FOOD': 'ખોરાક',
      'ANIMALS': 'પ્રાણીઓ',
      'CLOTHES': 'કપડાં',
      'BODY PARTS': 'શરીરના ભાગો',
      'Tap words to build a sentence...': 'વાક્ય બનાવવા માટે શબ્દો પર ટેપ કરો...',
      'Back to groups': 'જૂથો પર પાછા જાઓ',
      'No words in this category yet': 'આ શ્રેણીમાં હજી સુધી કોઈ શબ્દો નથી',
      'Add items from the Caregiver Dashboard': 'કેરગિવર ડૅશબોર્ડમાંથી વસ્તુઓ ઉમેરો',
      'Added: ': 'ઉમેરાયું: ',
      'Yes': 'હા',
      'No': 'ના',
      'Hello': 'નમસ્તે',
      'Thank you': 'આભાર',
      'Please': 'મહેરબાની કરીને',
      'What': 'શું',
      'Where': 'ક્યાં',
      'When': 'ક્યારે',
      'Why': 'શા માટે',
      'How': 'કેવી રીતે',
      'I': 'હું',
      'You': 'તમે',
      'Mom': 'મમ્મી',
      'Dad': 'પપ્પા',
      'Eat': 'ખાવ',
      'Eating': 'ખાઈ રહ્યા છે',
      'Running': 'દોડી રહ્યા છે',
      'Drink': 'પીવો',
      'Play': 'રમો',
      'Sleep': 'ઊંઘો',
      'Go': 'જાઓ',
      'Happy': 'ખુશ',
      'Hungry': 'ભૂખ્યું',
      'Sad': 'દુઃખી',
      'Angry': 'ગુસ્સે',
      'Tired': 'થાકેલું',
      'Now': 'હવે',
      'Later': 'પછી',
      'Today': 'આજે',
      'Tomorrow': 'આવતીકાલે',
    },
  };

  static String getBuiltInTranslation(String text, String targetLanguage) {
    if (targetLanguage == 'en' || text.trim().isEmpty) return text;
    final map = _builtInTranslations[targetLanguage];
    if (map != null) {
      final key = text.trim();
      if (map.containsKey(key)) return map[key]!;
      for (final entry in map.entries) {
        if (entry.key.toLowerCase() == key.toLowerCase()) {
          return entry.value;
        }
      }
    }
    return text;
  }

  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return '';
    if (targetLanguage == sourceLanguage) return normalizedText;

    // Check built-in translations first
    final builtIn = getBuiltInTranslation(normalizedText, targetLanguage);
    if (builtIn != normalizedText) {
      return builtIn;
    }

    try {
      final cacheKey = '${normalizedText}_${sourceLanguage}_$targetLanguage';
      if (_translationCache.containsKey(cacheKey)) {
        return _translationCache[cacheKey]!;
      }

      final translatorKey = '${sourceLanguage}_$targetLanguage';

      // Create translator if not exists
      if (!_translators.containsKey(translatorKey)) {
        final sourceLang = _getTranslateLanguage(sourceLanguage);
        final targetLang = _getTranslateLanguage(targetLanguage);

        _translators[translatorKey] = OnDeviceTranslator(
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
        );
      }

      final translator = _translators[translatorKey]!;
      
      // Check if models are downloaded
      final modelManager = OnDeviceTranslatorModelManager();
      final targetLang = _getTranslateLanguage(targetLanguage);
      final sourceLangModel = _getTranslateLanguage(sourceLanguage);
      
      final isSourceDownloaded = await modelManager.isModelDownloaded(sourceLangModel.bcpCode);
      if (!isSourceDownloaded) {
        debugPrint('Translation: Downloading model for $sourceLanguage...');
        await modelManager.downloadModel(sourceLangModel.bcpCode);
      }

      final isDownloaded = await modelManager.isModelDownloaded(targetLang.bcpCode);
      if (!isDownloaded) {
        debugPrint('Translation: Downloading model for $targetLanguage...');
        await modelManager.downloadModel(targetLang.bcpCode);
        debugPrint('Translation: Model downloaded for $targetLanguage');
      }

      // Translate
      final result = await translator.translateText(normalizedText);
      debugPrint('Translation: "$text" -> "$result" ($sourceLanguage -> $targetLanguage)');
      _translationCache[cacheKey] = result;
      return result;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original text on error
    }
  }

  TranslateLanguage _getTranslateLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return TranslateLanguage.english;
      case 'hi':
        return TranslateLanguage.hindi;
      case 'bn':
        return TranslateLanguage.bengali;
      case 'ta':
        return TranslateLanguage.tamil;
      case 'te':
        return TranslateLanguage.telugu;
      case 'kn':
        return TranslateLanguage.kannada;
      case 'mr':
        return TranslateLanguage.marathi;
      case 'gu':
        return TranslateLanguage.gujarati;
      case 'ml':
        // Malayalam is NOT supported by ML Kit Translation
        // Fall back to English
        debugPrint('Warning: Malayalam translation not supported by ML Kit, falling back to English');
        return TranslateLanguage.english;
      default:
        return TranslateLanguage.english;
    }
  }

  Future<bool> isModelDownloaded(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final language = _getTranslateLanguage(languageCode);
      return await modelManager.isModelDownloaded(language.bcpCode);
    } catch (e) {
      debugPrint('Error checking model: $e');
      return false;
    }
  }

  Future<void> downloadModel(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final language = _getTranslateLanguage(languageCode);
      await modelManager.downloadModel(language.bcpCode);
      debugPrint('Downloaded translation model for $languageCode');
    } catch (e) {
      debugPrint('Error downloading model: $e');
    }
  }

  Future<void> deleteModel(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final language = _getTranslateLanguage(languageCode);
      await modelManager.deleteModel(language.bcpCode);
      debugPrint('Deleted translation model for $languageCode');
    } catch (e) {
      debugPrint('Error deleting model: $e');
    }
  }

  void dispose() {
    for (var translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }
}

