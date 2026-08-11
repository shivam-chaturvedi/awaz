import 'dart:async';
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

  // Avoid ANRs by rendering the first frame ASAP, then initializing services in
  // the background from the widget tree.
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  Future<LocalizationDelegate>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<LocalizationDelegate> _initialize() async {
    try {
      // Initialize storage early so we can read saved settings, but don't block
      // startup indefinitely on slower devices.
      await StorageService().initialize().timeout(const Duration(seconds: 5), onTimeout: () {});

      final savedSettings = await StorageService().getSettings();

      final localizationDelegate = await LocalizationDelegate.create(
        fallbackLocale: 'en',
        supportedLocales: LanguageUtils.supportedLanguages,
        basePath: 'assets/translations',
      ).timeout(const Duration(seconds: 5));

      await localizationDelegate
          .changeLocale(localeFromString(savedSettings.currentLanguage))
          .timeout(const Duration(seconds: 3), onTimeout: () {});

      // Orientation lock should not block app startup.
      unawaited(SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]));

      // Defer potentially slow platform calls.
      unawaited(TTSService().initialize());
      unawaited(VocabularyInitializer.initializeDefaultVocabulary());

      return localizationDelegate;
    } catch (e) {
      debugPrint('Bootstrap init failed, falling back to English: $e');
      // Ensure we never block startup; return a minimal delegate.
      try {
        return await LocalizationDelegate.create(
          fallbackLocale: 'en',
          supportedLocales: const ['en'],
          basePath: 'assets/translations',
        ).timeout(const Duration(seconds: 3));
      } catch (_) {
        return await LocalizationDelegate.create(
          fallbackLocale: 'en',
          supportedLocales: const ['en'],
          basePath: 'assets/translations',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalizationDelegate>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Startup failed.'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _initFuture = _initialize()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting…'),
                  ],
                ),
              ),
            ),
          );
        }

        return LocalizedApp(snapshot.data!, const ChinnamApp());
      },
    );
  }
}

class ChinnamApp extends StatelessWidget {
  const ChinnamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SettingsProvider()..loadSettings()),
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
              title: translate('app_name'),
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
                final baseDirection = Directionality.of(context);
                final finalDirection = settings.leftHandMode
                    ? (baseDirection == TextDirection.rtl ? TextDirection.ltr : TextDirection.rtl)
                    : baseDirection;

                return Directionality(
                  textDirection: finalDirection,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(settings.iconSize),
                    ),
                    child: child!,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
