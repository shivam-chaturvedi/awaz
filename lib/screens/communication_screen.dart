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
  /// null = group home view; non-null = drill-down into that category
  String? _selectedCategory;

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
    await vocabularyProvider.loadCustomGroups();
    // Load all items so frozen row + sentence work even on home
    await vocabularyProvider.loadVocabularyItems();
  }

  void _selectCategory(String? category) {
    setState(() => _selectedCategory = category);
    final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
    vocabularyProvider.loadVocabularyItems(category: category);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CommunicationProvider, VocabularyProvider, SettingsProvider>(
      builder: (context, communicationProvider, vocabularyProvider, settingsProvider, _) {
        final settings = settingsProvider.settings;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sentence bar — always visible
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

              // Category breadcrumb/back row
              if (_selectedCategory != null)
                _buildBreadcrumb(_selectedCategory!),

              Expanded(
                child: vocabularyProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedCategory == null
                        ? _buildGroupGrid(vocabularyProvider, settings)
                        : _buildVocabularyGrid(
                            vocabularyProvider,
                            communicationProvider,
                            settings,
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Breadcrumb bar ──────────────────────────────────────────────────────────

  Widget _buildBreadcrumb(String category) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _selectCategory(null),
            tooltip: 'Back to groups',
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  // ─── Group home grid ─────────────────────────────────────────────────────────

  static const List<Color> _groupColors = [
    Color(0xFF5C6BC0), // indigo-ish  – All
    Color(0xFFEF5350), // red         – QUICK
    Color(0xFF26A69A), // teal        – ACTIONS
    Color(0xFFAB47BC), // purple      – FEELINGS
    Color(0xFF42A5F5), // blue        – PEOPLE
    Color(0xFFFF7043), // deep-orange – QUESTIONS
    Color(0xFF66BB6A), // green       – TIME
    Color(0xFFEC407A), // pink        – extras/custom
  ];

  static const List<IconData> _groupIcons = [
    Icons.grid_view_rounded,          // All
    Icons.flash_on_rounded,           // QUICK
    Icons.directions_run_rounded,     // ACTIONS
    Icons.sentiment_satisfied_rounded,// FEELINGS
    Icons.people_rounded,             // PEOPLE
    Icons.help_outline_rounded,       // QUESTIONS
    Icons.access_time_rounded,        // TIME
    Icons.label_rounded,              // custom
  ];

  Color _colorForGroup(int index) =>
      _groupColors[index.clamp(0, _groupColors.length - 1)];

  IconData _iconForGroup(int index) =>
      _groupIcons[index.clamp(0, _groupIcons.length - 1)];

  Widget _buildGroupGrid(
    VocabularyProvider vocabularyProvider,
    AppSettings settings,
  ) {
    return FutureBuilder<List<String>>(
      future: vocabularyProvider.getAllCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? vocabularyProvider.allGroups;

        // "All" tile + one tile per category
        final tiles = <_GroupTile>[
          const _GroupTile(label: 'All', index: 0),
          ...categories.asMap().entries.map(
                (e) => _GroupTile(label: e.value, index: e.key + 1),
              ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final crossCount = isWide ? 4 : 3;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: tiles.length,
              itemBuilder: (context, i) {
                final tile = tiles[i];
                final color = _colorForGroup(tile.index);
                final icon = _iconForGroup(tile.index);
                return _GroupTileWidget(
                  label: tile.label,
                  color: color,
                  icon: icon,
                  onTap: () => _selectCategory(
                    tile.label == 'All' ? null : tile.label,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Vocabulary (drill-down) grid ─────────────────────────────────────────

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
            const Icon(Icons.grid_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No words in ${_selectedCategory ?? 'this category'} yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Add items from the Caregiver Dashboard'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to groups'),
              onPressed: () => _selectCategory(null),
            ),
          ],
        ),
      );
    }

    final rows = settings.gridRows.clamp(1, 5);
    final columns = settings.gridColumns.clamp(2, 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLayout = constraints.maxWidth >= 900;
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
                final messenger = ScaffoldMessenger.of(context);
                final label = item.getLabel(settings.currentLanguage);
                await communicationProvider.addWordToSentence(item);
                if (!mounted) return;
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Added: $label'),
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
}

// ─── Helper data classes ──────────────────────────────────────────────────────

class _GroupTile {
  final String label;
  final int index;
  const _GroupTile({required this.label, required this.index});
}

// ─── Group tile widget ────────────────────────────────────────────────────────

class _GroupTileWidget extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _GroupTileWidget({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GroupTileWidget> createState() => _GroupTileWidgetState();
}

class _GroupTileWidgetState extends State<_GroupTileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(100),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 38, color: Colors.white),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
