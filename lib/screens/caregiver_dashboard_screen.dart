import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/settings_provider.dart';
import '../models/vocabulary_item.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../utils/image_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

// Conditional imports for non-web platforms
import 'dart:io' if (dart.library.html) 'package:awaz/services/file_stub.dart' as io;
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'package:awaz/services/path_provider_stub.dart' as path_provider;

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);
    final settings = Provider.of<SettingsProvider>(context).settings;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Caregiver Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vocabulary'),
              Tab(text: 'Usage Stats'),
              Tab(text: 'Backup'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVocabularyTab(vocabularyProvider, settings),
            _buildUsageStatsTab(),
            _buildBackupTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddVocabularyDialog(vocabularyProvider, settings),
          child: const Icon(Icons.add),
          tooltip: 'Add Vocabulary Item',
        ),
      ),
    );
  }

  Widget _buildVocabularyTab(
    VocabularyProvider vocabularyProvider,
    AppSettings settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Vocabulary Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...vocabularyProvider.vocabularyItems.map((item) {
          return Card(
            child: ListTile(
              leading: item.imagePath != null
                  ? Image.asset(
                      item.imagePath!,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    )
                  : const Icon(Icons.image),
              title: Text(item.getLabel(settings.currentLanguage)),
              subtitle: Text('Category: ${item.category}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Taps: ${item.tapCount}'),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _showEditVocabularyDialog(vocabularyProvider, item, settings),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteVocabularyItem(
                      vocabularyProvider,
                      item.id,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUsageStatsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUsageStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No usage data available'));
        }

        final stats = snapshot.data!;
        final wordCounts = stats['wordCounts'] as Map<String, int>;
        final categoryCounts = stats['categoryCounts'] as Map<String, int>;
        final totalTaps = stats['totalTaps'] as int;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usage Statistics',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Total Taps: $totalTaps'),
                    const SizedBox(height: 16),
                    const Text(
                      'Most Used Words',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...(wordCounts.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value)))
                        .take(10)
                        .map((entry) => ListTile(
                              title: Text(entry.key),
                              trailing: Text('${entry.value}'),
                            )),
                    const SizedBox(height: 16),
                    const Text(
                      'Category Usage',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...(categoryCounts.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value)))
                        .map((entry) => ListTile(
                              title: Text(entry.key),
                              trailing: Text('${entry.value}'),
                            )),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackupTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Backup & Export',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export All Data'),
            subtitle: const Text('Export vocabulary, usage logs, and settings'),
            onTap: () => _exportData(),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import Data'),
            subtitle: const Text('Import from backup file'),
            onTap: () => _importData(),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getUsageStatistics() async {
    final vocabularyItems = await _storageService.getAllVocabularyItems();
    final usageLogs = await _storageService.getUsageLogs();

    final wordCounts = <String, int>{};
    final categoryCounts = <String, int>{};
    int totalTaps = 0;

    for (var item in vocabularyItems) {
      wordCounts[item.getLabel('en')] = item.tapCount;
      categoryCounts[item.category] =
          (categoryCounts[item.category] ?? 0) + item.tapCount;
      totalTaps += item.tapCount;
    }

    return {
      'wordCounts': wordCounts,
      'categoryCounts': categoryCounts,
      'totalTaps': totalTaps,
    };
  }

  Future<void> _showAddVocabularyDialog(
    VocabularyProvider vocabularyProvider,
    AppSettings settings,
  ) async {
    final formKey = GlobalKey<FormState>();
    final wordController = TextEditingController();
    final categoryController = TextEditingController();
    String? selectedImagePath;
    String selectedCategory = 'QUICK';
    VocabularyColorScheme selectedColor = VocabularyColorScheme.blue;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Vocabulary Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: wordController,
                    decoration: const InputDecoration(
                      labelText: 'Word/Phrase (English)',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      'QUICK',
                      'QUESTIONS',
                      'PEOPLE',
                      'ACTIONS',
                      'FEELINGS',
                      'TIME',
                      'PLACES',
                      'FOOD',
                      'ANIMALS',
                      'CLOTHES',
                      'BODY PARTS',
                    ].map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedImagePath != null)
                    _buildImagePreview(selectedImagePath!),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                    onPressed: () async {
                      final image = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() => selectedImagePath = image.path);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final item = VocabularyItem(
                    id: _uuid.v4(),
                    imagePath: selectedImagePath,
                    labels: {'en': wordController.text},
                    category: selectedCategory,
                    colorScheme: selectedColor,
                  );
                  await vocabularyProvider.addVocabularyItem(item);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditVocabularyDialog(
    VocabularyProvider vocabularyProvider,
    VocabularyItem item,
    AppSettings settings,
  ) async {
    // Similar to add dialog but pre-filled
    // Implementation similar to _showAddVocabularyDialog
  }

  Future<void> _deleteVocabularyItem(
    VocabularyProvider vocabularyProvider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vocabularyProvider.deleteVocabularyItem(id);
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await _storageService.exportAllData();
      final jsonString = jsonEncode(data);
      
      if (kIsWeb) {
        // Web: Use share_plus to download the file
        if (context.mounted) {
          await Share.share(jsonString, subject: 'Awaz Backup');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data exported successfully')),
          );
        }
      } else {
        // Mobile/Desktop: Save to file and share
        final directory = await path_provider.getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/awaz_backup_${DateTime.now().millisecondsSinceEpoch}.json');
        await file.writeAsString(jsonString);
        
        if (context.mounted) {
          await Share.shareXFiles([XFile(file.path)]);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data exported successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    // Implementation for importing data
    // Would use file_picker to select a JSON file
  }

  Widget _buildImagePreview(String imagePath) {
    return buildImageFromPath(imagePath, height: 100);
  }
}

