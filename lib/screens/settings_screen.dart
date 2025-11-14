import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../utils/language_utils.dart';
import '../utils/color_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Language Selection
          ListTile(
            title: const Text('Language'),
            subtitle: Text(LanguageUtils.getLanguageName(settings.currentLanguage)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(settingsProvider),
          ),
          const Divider(),

          // Theme Selection
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_getThemeName(settings.themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showThemeDialog(settingsProvider),
          ),
          const Divider(),

          // Grid Layout
          ListTile(
            title: const Text('Grid Layout'),
            subtitle: Text('${settings.gridRows} x ${settings.gridColumns}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showGridLayoutDialog(settingsProvider, settings),
          ),
          const Divider(),

          // Accessibility Settings
          ExpansionTile(
            title: const Text('Accessibility'),
            children: [
              SwitchListTile(
                title: const Text('Frozen Row'),
                subtitle: const Text('Keep frequently used words visible'),
                value: settings.enableFrozenRow,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(enableFrozenRow: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Auto Speak'),
                subtitle: const Text('Automatically speak selected words'),
                value: settings.autoSpeak,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(autoSpeak: value),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageUtils.supportedLanguages.map((langCode) {
              return ListTile(
                title: Text(LanguageUtils.getLanguageName(langCode)),
                onTap: () {
                  settingsProvider.setLanguage(langCode);
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
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              onTap: () {
                settingsProvider.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              onTap: () {
                settingsProvider.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('High Contrast'),
              onTap: () {
                settingsProvider.setThemeMode(AppThemeMode.highContrast);
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
          title: const Text('Grid Layout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rows: $rows'),
              Slider(
                value: rows.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                label: '$rows',
                onChanged: (value) {
                  final newRows = value.toInt();
                  setState(() => rows = newRows);
                  settingsProvider.setGridLayout(newRows, columns);
                },
              ),
              Text('Columns: $columns'),
              Slider(
                value: columns.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                label: '$columns',
                onChanged: (value) {
                  final newColumns = value.toInt();
                  setState(() => columns = newColumns);
                  settingsProvider.setGridLayout(rows, newColumns);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.highContrast:
        return 'High Contrast';
    }
  }
}
