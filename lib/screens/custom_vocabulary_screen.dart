import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/vocabulary_item.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/color_utils.dart';
import '../utils/image_helper.dart';

class CustomVocabularyScreen extends StatefulWidget {
  const CustomVocabularyScreen({super.key});

  @override
  State<CustomVocabularyScreen> createState() => _CustomVocabularyScreenState();
}

class _CustomVocabularyScreenState extends State<CustomVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final _speechController = TextEditingController();
  final _newGroupController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  String _selectedCategory = 'CUSTOM';
  VocabularyColorScheme _selectedColor = VocabularyColorScheme.blue;
  String? _selectedImagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyProvider>(context, listen: false).loadCustomGroups();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _speechController.dispose();
    _newGroupController.dispose();
    super.dispose();
  }

  List<String> _buildCategoryOptions(VocabularyProvider vocabularyProvider) {
    final groups = <String>['CUSTOM', ...vocabularyProvider.allGroups];
    if (!groups.contains(_selectedCategory)) groups.add(_selectedCategory);
    return groups.toSet().toList();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  Future<void> _saveCustomTile(VocabularyProvider vocabularyProvider) async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);

    final labels = <String, String>{
      'en': _titleController.text.trim(),
    };
    final detailText = _detailController.text.trim();
    if (detailText.isNotEmpty) {
      labels['detail'] = detailText;
    }
    final speechText = _speechController.text.trim();
    if (speechText.isNotEmpty) {
      labels['speech'] = speechText;
    }

    final item = VocabularyItem(
      id: _uuid.v4(),
      imagePath: _selectedImagePath,
      labels: labels,
      category: _selectedCategory,
      colorScheme: _selectedColor,
    );

    await vocabularyProvider.addVocabularyItem(item);
    if (!mounted) return;

    setState(() {
      _selectedImagePath = null;
      _saving = false;
      _titleController.clear();
      _detailController.clear();
      _speechController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom tile added to vocabulary')),
    );
  }

  Future<void> _addGroup(VocabularyProvider vocabularyProvider) async {
    final name = _newGroupController.text.trim().toUpperCase();
    if (name.isEmpty) return;
    await vocabularyProvider.addCustomGroup(name);
    _newGroupController.clear();
    if (!mounted) return;
    setState(() {
      // If the new group was just created, pre-select it
      _selectedCategory = name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group "$name" created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final categoryOptions = _buildCategoryOptions(vocabularyProvider);

    // Ensure _selectedCategory is valid
    if (!categoryOptions.contains(_selectedCategory)) {
      _selectedCategory = categoryOptions.first;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Text(
              'Create Custom Tile',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload your own icon, enter a button title, and add contextual text that will be shown beneath the main label.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // ── Tile form ────────────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title (tone for button)',
                      hintText: 'e.g. "Call Mom"',
                    ),
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _detailController,
                    decoration: const InputDecoration(
                      labelText: 'Detail text',
                      hintText: 'Short sentence or context',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _speechController,
                    decoration: const InputDecoration(
                      labelText: 'Spoken phrase (optional)',
                      hintText: 'Text that should be spoken aloud',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categoryOptions
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<VocabularyColorScheme>(
                    initialValue: _selectedColor,
                    decoration: const InputDecoration(labelText: 'Color accent'),
                    items: VocabularyColorScheme.values
                        .map(
                          (scheme) => DropdownMenuItem(
                            value: scheme,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorUtils.getColorForScheme(scheme),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(scheme.name.toUpperCase()),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedColor = value);
                    },
                  ),
                ],
              ),
            ),

            // ── Image picker ─────────────────────────────────────────────
            const SizedBox(height: 20),
            const Text(
              'Add icon',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_selectedImagePath != null)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: buildImageFromPath(_selectedImagePath!),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),

            // ── Save button ──────────────────────────────────────────────
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _saveCustomTile(vocabularyProvider),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save custom tile'),
              ),
            ),

            // ════════════════════════════════════════════════════════════
            //  MANAGE GROUPS
            // ════════════════════════════════════════════════════════════
            const SizedBox(height: 32),
            Divider(thickness: 1.5, color: theme.dividerColor),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.label_rounded),
                const SizedBox(width: 8),
                Text(
                  'Manage Groups',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Create new categories that will appear as group tiles on the main communication screen.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),

            // Add group row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newGroupController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'New group name',
                      hintText: 'e.g. GAMES',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addGroup(vocabularyProvider),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                  onPressed: () => _addGroup(vocabularyProvider),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Built-in groups (read-only chips)
            Text(
              'Built-in groups',
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: VocabularyProvider.builtInGroups
                  .map(
                    (g) => Chip(
                      label: Text(g),
                      avatar: const Icon(Icons.lock_outline_rounded, size: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),

            // Custom groups (deletable chips)
            if (vocabularyProvider.customGroups.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Custom groups',
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: vocabularyProvider.customGroups
                    .map(
                      (g) => Chip(
                        label: Text(g),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        onDeleted: () async {
                          await vocabularyProvider.removeCustomGroup(g);
                          if (mounted && _selectedCategory == g) {
                            setState(() => _selectedCategory = 'CUSTOM');
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              'Current language: ${settingsProvider.settings.currentLanguage.toUpperCase()}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
