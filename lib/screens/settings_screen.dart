import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../utils/language_utils.dart';
import 'legal_info_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              translate('settings.title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Language Selection
          ListTile(
            title: Text(translate('settings.language')),
            subtitle: Text(LanguageUtils.getLanguageName(settings.currentLanguage)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(settingsProvider),
          ),
          const Divider(),

          // Theme Selection
          ListTile(
            title: Text(translate('settings.theme')),
            subtitle: Text(_getThemeName(settings.themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showThemeDialog(settingsProvider),
          ),
          const Divider(),

          // Grid Layout
          ListTile(
            title: Text(translate('settings.grid_layout')),
            subtitle: Text('${settings.gridRows} x ${settings.gridColumns}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showGridLayoutDialog(settingsProvider, settings),
          ),
          const Divider(),

          // Accessibility Settings
          ExpansionTile(
            title: Text(translate('settings.accessibility')),
            children: [
              SwitchListTile(
                title: Text(translate('settings.frozen_row')),
                subtitle: Text(translate('settings.frozen_row_desc')),
                value: settings.enableFrozenRow,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(enableFrozenRow: value),
                  );
                },
              ),
              SwitchListTile(
                title: Text(translate('settings.auto_speak')),
                subtitle: Text(translate('settings.auto_speak_desc')),
                value: settings.autoSpeak,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(autoSpeak: value),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              translate('settings.legal_section_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(translate('settings.privacy_policy')),
                    subtitle: Text(translate('settings.privacy_policy_desc')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    title: Text(translate('settings.terms_of_service')),
                    subtitle: Text(translate('settings.terms_of_service_desc')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('settings.language')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageUtils.supportedLanguages.map((langCode) {
              return ListTile(
                title: Text(LanguageUtils.getLanguageName(langCode)),
                onTap: () async {
                  await changeLocale(context, langCode);
                  await settingsProvider.setLanguage(langCode);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('settings.theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
              title: Text(translate('settings.theme_light')),
              onTap: () {
                settingsProvider.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
              ListTile(
                title: Text(translate('settings.theme_dark')),
              onTap: () {
                settingsProvider.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGridLayoutDialog(
    SettingsProvider settingsProvider,
    AppSettings settings,
  ) {
    int rows = settings.gridRows;
    int columns = settings.gridColumns;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(translate('settings.grid_layout')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridLayoutPreview(rows: rows, columns: columns),
              const SizedBox(height: 8),
              Text('Rows: $rows'),
              Slider(
                value: rows.toDouble(),
                min: 2,
                max: 5,
                divisions: 3,
                label: '$rows',
                onChanged: (value) {
                  setState(() => rows = value.toInt());
                },
              ),
              Text('Columns: $columns'),
              Slider(
                value: columns.toDouble(),
                min: 2,
                max: 4,
                divisions: 2,
                label: '$columns',
                onChanged: (value) {
                  setState(() => columns = value.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final shouldUpdate = rows != settings.gridRows || columns != settings.gridColumns;
                if (shouldUpdate) {
                  await settingsProvider.setGridLayout(rows, columns);
                }
                Navigator.pop(context);
              },
              child: Text(translate('settings.done')),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return translate('settings.theme_light');
      case AppThemeMode.dark:
        return translate('settings.theme_dark');
      case AppThemeMode.highContrast:
        return translate('settings.theme_high_contrast');
    }
  }
}

class GridLayoutPreview extends StatelessWidget {
  final int rows;
  final int columns;

  const GridLayoutPreview({
    super.key,
    required this.rows,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewRows = rows.clamp(1, 5) as int;
    final previewColumns = columns.clamp(1, 4) as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('settings.grid_layout_preview'),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.6),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(previewRows, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: List.generate(previewColumns, (columnIndex) {
                    return Expanded(
                      child: Container(
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
