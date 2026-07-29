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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletLayout = constraints.maxWidth >= 900;
          final gridContent = vocabularyProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildVocabularyGrid(
                  vocabularyProvider,
                  communicationProvider,
                  settings,
                  isTabletLayout: isTabletLayout,
                );
          final categoryBar = _buildCategoryBar(
            vocabularyProvider,
            isTablet: isTabletLayout,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

              Expanded(
                child: isTabletLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: gridContent),
                          categoryBar,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: gridContent),
                          categoryBar,
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
      },
    );
  }

  Widget _buildVocabularyGrid(
    VocabularyProvider vocabularyProvider,
    CommunicationProvider communicationProvider,
    AppSettings settings, {
    bool isTabletLayout = false,
  }) {
    final items = vocabularyProvider.vocabularyItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_off_rounded, size: 64, color: Colors.grey),
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

    final rows = settings.gridRows.clamp(1, 5);
    final columns = settings.gridColumns.clamp(2, 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalSpacing = isTabletLayout ? 12.0 : 8.0;
        final verticalSpacing = isTabletLayout ? 12.0 : 8.0;
        final padding = isTabletLayout ? 32.0 : 16.0;
        final gridPadding = isTabletLayout ? 16.0 : 8.0;
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
          padding: EdgeInsets.all(gridPadding),
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

  Widget _buildCategoryBar(
    VocabularyProvider vocabularyProvider, {
    bool isTablet = false,
  }) {
    final categories = vocabularyProvider.getCategories();

    if (categories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final buttons = <Widget>[
      _buildCategoryButton(
        label: 'All',
        onPressed: () => vocabularyProvider.loadVocabularyItems(),
        isTablet: isTablet,
      ),
      ...categories.map((category) {
        return _buildCategoryButton(
          label: category,
          onPressed: () => vocabularyProvider.loadVocabularyItems(category: category),
          isTablet: isTablet,
        );
      }).toList(),
    ];

    if (isTablet) {
      return Container(
        width: 220,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            left: BorderSide(
              color: theme.dividerColor,
              width: 1.0,
            ),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons,
          ),
        ),
      );
    }

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        children: buttons,
      ),
    );
  }

  Widget _buildCategoryButton({
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: isTablet
            ? const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0)
            : const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    final padding = isTablet
        ? const EdgeInsets.symmetric(vertical: 4.0)
        : const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0);

    if (isTablet) {
      return Padding(
        padding: padding,
        child: SizedBox(
          width: double.infinity,
          child: button,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: button,
    );
  }
}
