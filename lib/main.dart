import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import 'providers/vocabulary_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/communication_provider.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'services/vocabulary_initializer.dart';
import 'screens/home_screen.dart';
import 'utils/color_utils.dart';
import 'utils/language_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  ErrorWidget.builder = (details) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        'Something went wrong. Please restart the app.',
        style: TextStyle(color: Colors.red.shade200, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  };

  await StorageService().initialize();
  await TTSService().initialize();

  await VocabularyInitializer.initializeDefaultVocabulary();

  final localizationDelegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: LanguageUtils.supportedLanguages,
    basePath: 'assets/translations',
  );

  final savedSettings = await StorageService().getSettings();
  await localizationDelegate.changeLocale(localeFromString(savedSettings.currentLanguage));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(LocalizedApp(localizationDelegate, const AwazApp()));
}

class AwazApp extends StatelessWidget {
  const AwazApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MultiProvider(
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
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                localizationDelegate,
              ],
              supportedLocales: localizationDelegate.supportedLocales,
              locale: localizationDelegate.currentLocale,
              theme: theme,
              home: const AwazHomeScreen(),
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
      ),
    );
  }
}
