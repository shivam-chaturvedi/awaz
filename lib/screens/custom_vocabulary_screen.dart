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
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  String _selectedCategory = 'CUSTOM';
  VocabularyColorScheme _selectedColor = VocabularyColorScheme.blue;
  String? _selectedImagePath;
  bool _saving = false;

  static const _categoryOptions = [
    'CUSTOM',
    'QUICK',
    'QUESTIONS',
    'PEOPLE',
    'ACTIONS',
    'FEELINGS',
    'TIME',
    'PLACES',
    'FOOD',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _speechController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  Future<void> _saveCustomTile() async {
    if (_formKey.currentState?.validate() != true) return;
    final vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Custom Tile',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload your own icon, enter a button title, and add contextual text that will be shown beneath the main label.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
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
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Title is required'
                        : null,
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
                    items: _categoryOptions
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
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
                      if (value != null) {
                        setState(() => _selectedColor = value);
                      }
                    },
                  ),
                ],
              ),
            ),
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
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveCustomTile,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save custom tile'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Preview your custom content',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Once you save, the tile will appear in the main communication grid and the sentence bar will read the text you entered.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Current language: ${settingsProvider.settings.currentLanguage.toUpperCase()}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
