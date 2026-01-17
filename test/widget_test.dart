import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:awaz/main.dart';
import 'package:awaz/utils/language_utils.dart';

void main() {
  testWidgets('ChinnamApp boots with localized title', (WidgetTester tester) async {
    final localizationDelegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: LanguageUtils.supportedLanguages,
      basePath: 'assets/translations',
    );
    await localizationDelegate.changeLocale(localeFromString('en'));

    await tester.pumpWidget(
      LocalizedApp(
        localizationDelegate,
        const ChinnamApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Chinnam AAC'), findsWidgets);
  });
}
