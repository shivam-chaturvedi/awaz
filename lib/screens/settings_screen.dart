import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/app_settings.dart';
import '../utils/language_utils.dart';
import '../services/storage_service.dart';
import 'legal_info_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final StorageService _storageService = StorageService();

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
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _showLanguageDialog(settingsProvider),
          ),
          const Divider(),

          // Theme Selection
          ListTile(
            title: Text(translate('settings.theme')),
            subtitle: Text(_getThemeName(settings.themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _showThemeDialog(settingsProvider),
          ),
          const Divider(),

          // Grid Layout
          ListTile(
            title: Text(translate('settings.grid_layout')),
            subtitle: Text('${settings.gridRows} x ${settings.gridColumns}'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
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
              SwitchListTile(
                title: const Text('Left-Hand Mode'),
                subtitle: const Text('Moves primary buttons to the left for easier reach'),
                value: settings.leftHandMode,
                onChanged: (value) {
                  settingsProvider.updateSettings(
                    settings.copyWith(leftHandMode: value),
                  );
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Voice Speed',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(settings.speechRate * 10).round()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust the speed of text-to-speech output',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        const Text('1', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: (settings.speechRate * 10).roundToDouble().clamp(1.0, 10.0),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: '${(settings.speechRate * 10).round()}',
                            onChanged: (value) {
                              settingsProvider.updateSettings(
                                settings.copyWith(speechRate: value / 10.0),
                              );
                            },
                          ),
                        ),
                        const Text('10', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),

          // Backup & Transfer
          ExpansionTile(
            title: const Text('Backup & Transfer Words'),
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_rounded),
                title: const Text('Export Data to another device'),
                subtitle: const Text('Export your custom vocabulary and settings'),
                onTap: () => _exportData(),
              ),
              ListTile(
                leading: const Icon(Icons.file_upload_rounded),
                title: const Text('Import Data from device'),
                subtitle: const Text('Restore vocabulary from a backup file'),
                onTap: () => _importData(),
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
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
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
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfUseScreen(),
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
      builder: (dialogContext) => AlertDialog(
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
                  if (mounted) {
                    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
                    vocabProvider.translateAllVocabulary(langCode);
                  }
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
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
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
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
                if (dialogContext.mounted) Navigator.pop(dialogContext);
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

  Future<void> _exportData() async {
    try {
      final data = await _storageService.exportAllData();
      final jsonString = jsonEncode(data);

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/awaz_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], subject: 'Awaz AAC Backup');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        await _storageService.importData(data);

        if (!mounted) return;

        // Reload settings and vocabulary
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        await settingsProvider.loadSettings();

        if (!mounted) return;
        final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
        await vocabProvider.loadVocabularyItems();
        await vocabProvider.loadCustomGroups();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing data: $e')),
      );
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
    final previewRows = rows.clamp(1, 5);
    final previewColumns = columns.clamp(1, 4);

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
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.6),
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
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
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
