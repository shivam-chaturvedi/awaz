import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../widgets/vocabulary_grid_item.dart';
import '../widgets/frozen_row.dart';
import '../widgets/sentence_bar.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    await settingsProvider.loadSettings();
    await vocabularyProvider.loadVocabularyItems();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CommunicationProvider, VocabularyProvider, SettingsProvider>(
      builder: (context, communicationProvider, vocabularyProvider, settingsProvider, _) {
        final settings = settingsProvider.settings;

        return SafeArea(
      child: Column(
        children: [
          // Sentence bar - always visible and prominent
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const SentenceBar(),
          ),
          
          // Frozen row (if enabled)
          if (settings.enableFrozenRow)
            FrozenRow(items: vocabularyProvider.getFrozenRowItems()),
          
          // Main vocabulary grid
          Expanded(
            child: vocabularyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildVocabularyGrid(vocabularyProvider, communicationProvider, settings),
          ),
          
          // Category bar
          _buildCategoryBar(vocabularyProvider),
        ],
      ),
    );
      },
    );
  }

  Widget _buildVocabularyGrid(
    VocabularyProvider vocabularyProvider,
    CommunicationProvider communicationProvider,
    AppSettings settings,
  ) {
    final items = vocabularyProvider.vocabularyItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No vocabulary items yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Add items from the Caregiver Dashboard'),
          ],
        ),
      );
    }

    final rows = settings.gridRows.clamp(1, 8);
    final columns = settings.gridColumns.clamp(2, 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalSpacing = 8.0;
        final verticalSpacing = 8.0;
        final padding = 16.0;
        final gridWidth = constraints.maxWidth;
        final gridHeight = constraints.maxHeight;

        final availableWidth = math.max(
          gridWidth - padding - ((columns - 1) * horizontalSpacing),
          columns * 36.0,
        );
        final availableHeight = math.max(
          gridHeight - ((rows - 1) * verticalSpacing),
          rows * 48.0,
        );

        final tileWidth = availableWidth / columns;
        final tileHeight = availableHeight / rows;
        final childAspectRatio = tileHeight > 0 ? tileWidth / tileHeight : 1.0;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: horizontalSpacing,
            mainAxisSpacing: verticalSpacing,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return VocabularyGridItem(
              item: item,
              iconSize: settings.iconSize,
              showTextLabels: settings.showTextLabels,
              isDark: isDark,
              onTap: () async {
                debugPrint('Tapped item: ${item.getLabel(settings.currentLanguage)}');
                debugPrint('Current sentence before: ${communicationProvider.currentSentence.length}');

                await communicationProvider.addWordToSentence(item);

                debugPrint('Current sentence after: ${communicationProvider.currentSentence.length}');

                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added: ${item.getLabel(settings.currentLanguage)}'),
                    duration: const Duration(milliseconds: 500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryBar(VocabularyProvider vocabularyProvider) {
    final categories = vocabularyProvider.getCategories();
    
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => vocabularyProvider.loadVocabularyItems(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('All', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }
          
          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => vocabularyProvider.loadVocabularyItems(category: category),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(category),
            ),
          );
        },
      ),
    );
  }
}
