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

          // Icon Size
          ListTile(
            title: const Text('Icon Size'),
            subtitle: Slider(
              value: settings.iconSize,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${(settings.iconSize * 100).toInt()}%',
              onChanged: (value) {
                settingsProvider.setIconSize(value);
              },
            ),
          ),
          const Divider(),

          // Speech Settings
          ExpansionTile(
            title: const Text('Speech Settings'),
            children: [
              ListTile(
                title: const Text('Speech Rate'),
                subtitle: Slider(
                  value: settings.speechRate,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  label: '${(settings.speechRate * 100).toInt()}%',
                  onChanged: (value) {
                    settingsProvider.setSpeechRate(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Speech Pitch'),
                subtitle: Slider(
                  value: settings.speechPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${settings.speechPitch.toStringAsFixed(1)}',
                  onChanged: (value) {
                    settingsProvider.setSpeechPitch(value);
                  },
                ),
              ),
            ],
          ),

          // Display Settings
          ExpansionTile(
            title: const Text('Display Settings'),
            children: [
              SwitchListTile(
                title: const Text('Show Text Labels'),
                value: settings.showTextLabels,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(showTextLabels: value),
                  );
                },
              ),
            ],
          ),

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
              SwitchListTile(
                title: const Text('Screen Reader Support'),
                value: settings.enableScreenReader,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(enableScreenReader: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Switch Access'),
                value: settings.enableSwitchAccess,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(enableSwitchAccess: value),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grid Layout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rows: ${settings.gridRows}'),
            Slider(
              value: settings.gridRows.toDouble(),
              min: 2,
              max: 8,
              divisions: 6,
              label: '${settings.gridRows}',
              onChanged: (value) {
                settingsProvider.setGridLayout(
                  value.toInt(),
                  settings.gridColumns,
                );
              },
            ),
            Text('Columns: ${settings.gridColumns}'),
            Slider(
              value: settings.gridColumns.toDouble(),
              min: 2,
              max: 8,
              divisions: 6,
              label: '${settings.gridColumns}',
              onChanged: (value) {
                settingsProvider.setGridLayout(
                  settings.gridRows,
                  value.toInt(),
                );
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


