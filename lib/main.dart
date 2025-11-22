import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/communication_provider.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'screens/communication_screen.dart';
import 'utils/color_utils.dart';
import 'models/app_settings.dart';
import 'services/vocabulary_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageService().initialize();
  await TTSService().initialize();
  
  await VocabularyInitializer.initializeDefaultVocabulary();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AwazApp());
}

class AwazApp extends StatelessWidget {
  const AwazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => VocabularyProvider()),
        ChangeNotifierProxyProvider2<VocabularyProvider, SettingsProvider, CommunicationProvider>(
          create: (context) {
            final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
            final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
            return CommunicationProvider(vocabularyProvider, settingsProvider);
          },
          update: (context, vocabularyProvider, settingsProvider, previous) {
            if (previous != null) {
              // Update existing provider without creating a new instance
              previous.updateProviders(vocabularyProvider, settingsProvider);
              return previous;
            }
            // Only create new instance if previous is null
            return CommunicationProvider(vocabularyProvider, settingsProvider);
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;
          final theme = ColorUtils.getThemeForMode(settings.themeMode);

          return MaterialApp(
            title: 'Awaz AAC',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const CommunicationScreen(),
            // Enable accessibility
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.iconSize),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
