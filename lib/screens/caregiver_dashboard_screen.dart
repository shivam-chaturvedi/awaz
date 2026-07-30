import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/settings_provider.dart';
import '../models/vocabulary_item.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../utils/color_utils.dart';
import '../utils/image_helper.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyProvider>(context, listen: false).loadCustomGroups();
    });
  }

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
          tooltip: 'Add Vocabulary Item',
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  // ─── Vocabulary tab ──────────────────────────────────────────────────────

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
        const SizedBox(height: 4),
        Text(
          'Tap any block to edit, change group, change colour or delete.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        ...vocabularyProvider.vocabularyItems.map((item) {
          return _VocabularyBlockCard(
            item: item,
            languageCode: settings.currentLanguage,
            onTap: () => _showBlockOptionsSheet(
              context,
              vocabularyProvider,
              item,
            ),
          );
        }),
      ],
    );
  }

  // ─── Block options bottom sheet ──────────────────────────────────────────

  void _showBlockOptionsSheet(
    BuildContext context,
    VocabularyProvider vocabularyProvider,
    VocabularyItem item,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Word label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    item.getLabel('en'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Category: ${item.category}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 20),

                // ── Change Group
                ListTile(
                  leading: const Icon(Icons.label_rounded),
                  title: const Text('Change Group'),
                  subtitle: Text('Currently: ${item.category}'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showChangeGroupDialog(context, vocabularyProvider, item);
                  },
                ),

                // ── Change Colour
                ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorUtils.getColorForScheme(item.colorScheme),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  title: const Text('Change Colour'),
                  subtitle: Text('Currently: ${item.colorScheme.name}'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showChangeColourDialog(context, vocabularyProvider, item);
                  },
                ),

                // ── Delete
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Delete Block', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _deleteVocabularyItem(vocabularyProvider, item.id);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Change Group dialog ─────────────────────────────────────────────────

  void _showChangeGroupDialog(
    BuildContext context,
    VocabularyProvider vocabularyProvider,
    VocabularyItem item,
  ) {
    String selectedGroup = item.category;
    final allGroups = vocabularyProvider.allGroups;
    // Include current category even if not in allGroups list
    final options = allGroups.contains(selectedGroup)
        ? allGroups
        : [selectedGroup, ...allGroups];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Change Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${item.getLabel('en')}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                ),
                items: options
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDlgState(() => selectedGroup = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final updated = item.copyWith(category: selectedGroup);
                await vocabularyProvider.updateVocabularyItem(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Moved "${item.getLabel('en')}" to $selectedGroup',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Change Colour dialog ────────────────────────────────────────────────

  // The 10 user-facing colour choices
  static const _colourOptions = <({String label, VocabularyColorScheme scheme})>[
    (label: 'White',  scheme: VocabularyColorScheme.white),
    (label: 'Black',  scheme: VocabularyColorScheme.black),
    (label: 'Red',    scheme: VocabularyColorScheme.red),
    (label: 'Blue',   scheme: VocabularyColorScheme.blue),
    (label: 'Green',  scheme: VocabularyColorScheme.green),
    (label: 'Yellow', scheme: VocabularyColorScheme.yellow),
    (label: 'Orange', scheme: VocabularyColorScheme.orange),
    (label: 'Purple', scheme: VocabularyColorScheme.purple),
    (label: 'Pink',   scheme: VocabularyColorScheme.pink),
    (label: 'Grey',   scheme: VocabularyColorScheme.gray),
  ];

  void _showChangeColourDialog(
    BuildContext context,
    VocabularyProvider vocabularyProvider,
    VocabularyItem item,
  ) {
    VocabularyColorScheme selected = item.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Change Colour'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${item.getLabel('en')}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colourOptions.map((opt) {
                  final isSelected = selected == opt.scheme;
                  final color = ColorUtils.getColorForScheme(opt.scheme);
                  return GestureDetector(
                    onTap: () => setDlgState(() => selected = opt.scheme),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(ctx).colorScheme.primary
                                  : Colors.grey.shade400,
                              width: isSelected ? 3.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withAlpha(128),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                                  size: 22,
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final updated = item.copyWith(colorScheme: selected);
                await vocabularyProvider.updateVocabularyItem(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Colour updated for "${item.getLabel('en')}"',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Usage stats tab ─────────────────────────────────────────────────────

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

  // ─── Backup tab ───────────────────────────────────────────────────────────

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
            leading: const Icon(Icons.file_download_rounded),
            title: const Text('Export All Data'),
            subtitle: const Text('Export vocabulary, usage logs, and settings'),
            onTap: () => _exportData(),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.file_upload_rounded),
            title: const Text('Import Data'),
            subtitle: const Text('Import from backup file'),
            onTap: () => _importData(),
          ),
        ),
      ],
    );
  }

  // ─── Add vocabulary dialog ────────────────────────────────────────────────

  Future<void> _showAddVocabularyDialog(
    VocabularyProvider vocabularyProvider,
    AppSettings settings,
  ) async {
    final formKey = GlobalKey<FormState>();
    final wordController = TextEditingController();
    String? selectedImagePath;
    String selectedCategory = vocabularyProvider.allGroups.isNotEmpty
        ? vocabularyProvider.allGroups.first
        : 'QUICK';
    VocabularyColorScheme selectedColor = VocabularyColorScheme.blue;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
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
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: vocabularyProvider.allGroups
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDlgState(() => selectedCategory = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedImagePath != null)
                    _buildImagePreview(selectedImagePath!),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image_rounded),
                    label: const Text('Select Image'),
                    onPressed: () async {
                      final image = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setDlgState(() => selectedImagePath = image.path);
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

  // ─── Delete ───────────────────────────────────────────────────────────────

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vocabularyProvider.deleteVocabularyItem(id);
    }
  }

  // ─── Stats helper ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _getUsageStatistics() async {
    final vocabularyItems = await _storageService.getAllVocabularyItems();
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

  // ─── Export / Import ──────────────────────────────────────────────────────

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
    // Implementation for importing data
    // Would use file_picker to select a JSON file
  }

  Widget _buildImagePreview(String imagePath) {
    return buildImageFromPath(imagePath, height: 100);
  }
}

// ─── Vocabulary block card widget ─────────────────────────────────────────────

class _VocabularyBlockCard extends StatelessWidget {
  final VocabularyItem item;
  final String languageCode;
  final VoidCallback onTap;

  const _VocabularyBlockCard({
    required this.item,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.getColorForScheme(item.colorScheme);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Colour dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 10),

              // Image (if any)
              if (item.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_rounded),
                      ),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.image_outlined, size: 44, color: Colors.grey),
                ),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.getLabel(languageCode),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Group: ${item.category}  •  Taps: ${item.tapCount}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Edit hint icon
              const Icon(Icons.more_vert_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
