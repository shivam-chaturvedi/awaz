import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/scan_provider.dart';
import '../models/app_settings.dart';
import '../widgets/vocabulary_grid_item.dart';
import '../widgets/frozen_row.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/scan_highlight_overlay.dart';
import '../services/translation_service.dart';
import '../utils/image_helper.dart';

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

    // Configure scan for the initial state after data loads
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScanConfig());
  }

  void _selectCategory(String? category) {
    setState(() => _selectedCategory = category);
    final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
    vocabularyProvider.loadVocabularyItems(category: category);
    // Restart scan for the new screen context
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScanConfig());
  }

  // ─── Scan Mode helpers ────────────────────────────────────────────────────

  /// Recomputes the scan layout and calls [ScanProvider.configureScreen].
  /// Must be called via post-frame callback to avoid rebuild loops.
  void _updateScanConfig() {
    if (!mounted) return;
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    if (!scanProvider.isScanModeEnabled) return;

    final communicationProvider =
        Provider.of<CommunicationProvider>(context, listen: false);
    final vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    // ── Row 0: top-controls row ──────────────────────────────────────────
    final hasWords = communicationProvider.currentSentence.isNotEmpty;
    int topCount = 0;
    if (hasWords) topCount += 2; // Speak + Undo
    topCount += 1;               // Clear
    if (_selectedCategory != null) topCount += 1; // Back to groups
    topCount += 1;               // Scan mode toggle

    final rowCounts = <int>[topCount];

    // ── Rows 1..N: vocabulary/group-tile grid rows ───────────────────────
    if (_selectedCategory == null) {
      // Group home: 1 (All) + all group categories
      final totalTiles = 1 + vocabularyProvider.allGroups.length;
      final baseRows = settings.groupGridRows.clamp(1, 5);
      final baseCols = settings.groupGridColumns.clamp(2, 5);
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      final crossCount = isPortrait ? math.min(baseRows, baseCols) : math.max(baseRows, baseCols);
      int remaining = totalTiles;
      while (remaining > 0) {
        rowCounts.add(math.min(remaining, crossCount));
        remaining -= crossCount;
      }
    } else {
      // Vocabulary drill-down
      final items = vocabularyProvider.vocabularyItems;
      if (items.isNotEmpty) {
        final baseRows = settings.gridRows.clamp(1, 5);
        final baseCols = settings.gridColumns.clamp(2, 4);
        final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final columns = isPortrait ? math.min(baseRows, baseCols) : math.max(baseRows, baseCols);
        int startIdx = 0;
        while (startIdx < items.length) {
          final endIdx = math.min(startIdx + columns, items.length);
          rowCounts.add(endIdx - startIdx);
          startIdx += columns;
        }
      }
    }

    scanProvider.configureScreen(rowCounts);
  }

  /// Intercepts screen taps when scan mode is ON.
  void _handleScanTap() {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final result = scanProvider.onTap();
    if (result == null) return; // row → column phase transition; no action yet

    final (row, col) = result;
    final communicationProvider =
        Provider.of<CommunicationProvider>(context, listen: false);
    final vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    if (row == 0) {
      _executeScanTopControl(col, communicationProvider, scanProvider);
    } else {
      _executeScanVocabItem(
          row - 1, col, communicationProvider, vocabularyProvider, settings, scanProvider);
    }
  }

  /// Executes the top-control action at [col] in the top-controls row (row 0).
  void _executeScanTopControl(
    int col,
    CommunicationProvider comm,
    ScanProvider scan,
  ) {
    final hasWords = comm.currentSentence.isNotEmpty;
    int idx = 0;

    if (hasWords) {
      if (col == idx++) {
        // Speak sentence
        comm.speakCurrentSentence().then((_) {
          if (mounted) scan.restartRowScan();
        });
        return;
      }
      if (col == idx++) {
        // Undo last word
        comm.removeLastWord();
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateScanConfig());
        scan.restartRowScan();
        return;
      }
    }

    if (col == idx++) {
      // Clear sentence
      comm.clearSentence();
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateScanConfig());
      scan.restartRowScan();
      return;
    }

    if (_selectedCategory != null && col == idx++) {
      // Back to groups
      _selectCategory(null); // _selectCategory already re-configures scan
      return;
    }

    // Scan Mode toggle (always last)
    if (col == idx) {
      scan.toggleScanMode(); // turns scan OFF
      return;
    }

    scan.restartRowScan();
  }

  /// Executes the vocabulary/group action at grid row [vocabRow], column [col].
  void _executeScanVocabItem(
    int vocabRow,
    int col,
    CommunicationProvider comm,
    VocabularyProvider vocab,
    AppSettings settings,
    ScanProvider scan,
  ) {
    if (_selectedCategory == null) {
      // Group home grid
      final baseRows = settings.groupGridRows.clamp(1, 5);
      final baseCols = settings.groupGridColumns.clamp(2, 5);
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      final crossCount = isPortrait ? math.min(baseRows, baseCols) : math.max(baseRows, baseCols);
      final tileIndex = vocabRow * crossCount + col;

      if (tileIndex == 0) {
        _selectCategory('All');
      } else {
        final groupIdx = tileIndex - 1;
        final allGroups = vocab.allGroups;
        if (groupIdx < allGroups.length) {
          _selectCategory(allGroups[groupIdx]);
        } else {
          scan.restartRowScan();
        }
      }
    } else {
      // Vocabulary items grid
      final items = vocab.vocabularyItems;
      final baseRows = settings.gridRows.clamp(1, 5);
      final baseCols = settings.gridColumns.clamp(2, 4);
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      final columns = isPortrait ? math.min(baseRows, baseCols) : math.max(baseRows, baseCols);
      final itemIndex = vocabRow * columns + col;

      if (itemIndex < items.length) {
        final item = items[itemIndex];
        final messenger = ScaffoldMessenger.of(context);
        final label = item.getLabel(settings.currentLanguage);
        final addedPrefix = TranslationService.getBuiltInTranslation(
            'Added: ', settings.currentLanguage);

        comm.addWordToSentence(item).then((_) {
          if (!mounted) return;
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(SnackBar(
            content: Text('$addedPrefix$label'),
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating,
          ));
          WidgetsBinding.instance.addPostFrameCallback((_) => _updateScanConfig());
          scan.restartRowScan();
        });
      } else {
        scan.restartRowScan();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        // Runs on every ScanProvider notification (e.g., toggle ON, timer tick).
        // configureScreen() is a no-op when layout hasn't changed → no loop.
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateScanConfig());
        return Consumer3<CommunicationProvider, VocabularyProvider, SettingsProvider>(
          builder: (context, communicationProvider, vocabularyProvider, settingsProvider, _) {
            final settings = settingsProvider.settings;
            final scanOn = scanProvider.isScanModeEnabled;

            return SafeArea(
              child: GestureDetector(
                // opaque: this GestureDetector is always in the hit-test tree.
                // AbsorbPointer (below) prevents children from competing in
                // the gesture arena when scan is ON, so onTapDown always wins.
                behavior: HitTestBehavior.opaque,
                onTapDown: scanOn ? (_) => _handleScanTap() : null,
                child: AbsorbPointer(
                  // Block all child pointer events during scanning so the
                  // outer GestureDetector is the sole tap recipient.
                  absorbing: scanOn,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Sentence bar — always visible ──────────────────────
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

                    // ── Scan action bar — always visible ───────────────────
                    _buildScanBar(
                      context,
                      scanProvider,
                      communicationProvider,
                      settings,
                    ),

                    // ── Frozen row (if enabled) ────────────────────────────
                    if (settings.enableFrozenRow)
                      FrozenRow(items: vocabularyProvider.getFrozenRowItems()),

                    // ── Category breadcrumb/back row ───────────────────────
                    if (_selectedCategory != null)
                      _buildBreadcrumb(
                        _selectedCategory!,
                        settings.currentLanguage,
                        scanProvider,
                      ),

                    // ── Main grid area ─────────────────────────────────────
                    Expanded(
                      child: vocabularyProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _selectedCategory == null
                              ? _buildGroupGrid(
                                  vocabularyProvider, settings, scanProvider)
                              : _buildVocabularyGrid(
                                  vocabularyProvider,
                                  communicationProvider,
                                  settings,
                                  scanProvider,
                                ),
                    ),
                  ],
                ),
                ), // AbsorbPointer
              ),
            );
          },
        );
      },
    );
  }

  // ─── Scan action bar ──────────────────────────────────────────────────────

  /// A thin bar always shown below the SentenceBar.
  ///
  /// When scan mode is OFF it shows only the scan toggle button.
  /// When scan mode is ON it shows all scannable top-controls with visual
  /// highlights for row-level (whole bar) and column-level (individual button).
  Widget _buildScanBar(
    BuildContext context,
    ScanProvider scanProvider,
    CommunicationProvider communicationProvider,
    AppSettings settings,
  ) {
    final hasWords = communicationProvider.currentSentence.isNotEmpty;
    final scanOn = scanProvider.isScanModeEnabled;

    final isRowHighlighted = scanOn &&
        scanProvider.phase == ScanPhase.row &&
        scanProvider.highlightedRow == 0;
    final isColPhase = scanOn &&
        scanProvider.phase == ScanPhase.column &&
        scanProvider.selectedRow == 0;

    // Build the ordered list of visible controls with their scan-column index.
    int colIdx = 0;
    final controlWidgets = <Widget>[];

    bool colHighlighted(int idx) => isColPhase && scanProvider.highlightedColumn == idx;

    if (scanOn) {
      if (hasWords) {
        final speakIdx = colIdx++;
        controlWidgets.add(_scanButton(
          icon: Icons.volume_up_rounded,
          label: 'Speak',
          color: Colors.green,
          highlighted: colHighlighted(speakIdx),
        ));
        final undoIdx = colIdx++;
        controlWidgets.add(_scanButton(
          icon: Icons.backspace_rounded,
          label: 'Undo',
          color: Colors.orange,
          highlighted: colHighlighted(undoIdx),
        ));
      }
      final clearIdx = colIdx++;
      controlWidgets.add(_scanButton(
        icon: Icons.clear_all_rounded,
        label: 'Clear',
        color: Colors.red,
        highlighted: colHighlighted(clearIdx),
      ));
      if (_selectedCategory != null) {
        final backIdx = colIdx++;
        controlWidgets.add(_scanButton(
          icon: Icons.arrow_back_rounded,
          label: 'Back',
          color: Theme.of(context).colorScheme.onSurface,
          highlighted: colHighlighted(backIdx),
        ));
      }
    }

    // Scan toggle — always the last control
    final scanToggleIdx = colIdx;
    final scanToggleWidget = _scanButton(
      icon: scanOn ? Icons.accessibility_new_rounded : Icons.accessibility_rounded,
      label: scanOn ? 'Scan ON' : 'Scan',
      color: scanOn ? const Color(0xFF1E88E5) : Colors.grey,
      highlighted: isColPhase && scanProvider.highlightedColumn == scanToggleIdx,
      // Only allow direct tap when scan mode is off (otherwise GestureDetector handles it)
      onTap: scanOn ? null : scanProvider.toggleScanMode,
    );

    Widget bar = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          if (scanOn) ...[
            ...controlWidgets,
            const Spacer(),
          ] else ...[
            const Spacer(),
          ],
          scanToggleWidget,
        ],
      ),
    );

    // Highlight the whole bar when it's row 0 in row-scan phase
    if (isRowHighlighted) {
      bar = ScanHighlightOverlay(
        highlighted: true,
        borderRadius: BorderRadius.circular(4),
        child: bar,
      );
    }

    return bar;
  }

  /// A compact icon+label chip used inside the scan bar.
  Widget _scanButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool highlighted,
    VoidCallback? onTap,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (highlighted) {
      content = ScanHighlightOverlay(
        highlighted: true,
        borderRadius: BorderRadius.circular(6),
        borderWidth: 2.5,
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }

  // ─── Breadcrumb bar ───────────────────────────────────────────────────────

  Widget _buildBreadcrumb(
    String category,
    String languageCode,
    ScanProvider scanProvider,
  ) {
    final translatedCategory =
        TranslationService.getBuiltInTranslation(category, languageCode);
    final backTooltip =
        TranslationService.getBuiltInTranslation('Back to groups', languageCode);

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            // In scan mode, taps are handled by GestureDetector; no direct action here.
            onPressed: scanProvider.isScanModeEnabled ? null : () => _selectCategory(null),
            tooltip: backTooltip,
          ),
          const SizedBox(width: 4),
          Text(
            translatedCategory,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  // ─── Group home grid ──────────────────────────────────────────────────────

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
    Icons.grid_view_rounded,           // All
    Icons.flash_on_rounded,            // QUICK
    Icons.directions_run_rounded,      // ACTIONS
    Icons.sentiment_satisfied_rounded, // FEELINGS
    Icons.people_rounded,              // PEOPLE
    Icons.help_outline_rounded,        // QUESTIONS
    Icons.access_time_rounded,         // TIME
    Icons.label_rounded,               // custom
  ];

  Color _colorForGroup(int index) =>
      _groupColors[index.clamp(0, _groupColors.length - 1)];

  IconData _iconForGroup(int index) =>
      _groupIcons[index.clamp(0, _groupIcons.length - 1)];

  Widget _buildGroupGrid(
    VocabularyProvider vocabularyProvider,
    AppSettings settings,
    ScanProvider scanProvider,
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
            final baseRows = settings.groupGridRows.clamp(1, 5);
            final baseCols = settings.groupGridColumns.clamp(2, 5);
            final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
            final columns = isPortrait ? math.min(baseRows, baseCols) : math.max(baseRows, baseCols);
            final crossCount = columns;
            
            // Calculate how many rows we actually have to properly size the highlight
            final totalTiles = tiles.length;
            final rows = (totalTiles / crossCount).ceil();
            
            final padding = 16.0;
            final spacing = 12.0;

            // ── Determine scan highlight state for this grid ──────────────
            final scanOn = scanProvider.isScanModeEnabled;

            // Row highlight: scan row 1..N → vocabRow = scanRow - 1
            final highlightedVocabRow = (scanOn &&
                    scanProvider.phase == ScanPhase.row &&
                    scanProvider.highlightedRow > 0)
                ? scanProvider.highlightedRow - 1
                : -1;

            // Column highlight
            final isColPhaseGroup = scanOn &&
                scanProvider.phase == ScanPhase.column &&
                scanProvider.selectedRow > 0;
            final selectedGroupRow =
                isColPhaseGroup ? scanProvider.selectedRow - 1 : -1;

            final gridWidget = GridView.builder(
              padding: EdgeInsets.all(padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1.1,
              ),
              itemCount: tiles.length,
              itemBuilder: (context, i) {
                final tile = tiles[i];
                final color = _colorForGroup(tile.index);
                final icon = _iconForGroup(tile.index);

                final itemRow = i ~/ crossCount;
                final itemCol = i % crossCount;
                final isItemHighlighted = isColPhaseGroup &&
                    selectedGroupRow == itemRow &&
                    scanProvider.highlightedColumn == itemCol;

                return ScanHighlightOverlay(
                  highlighted: isItemHighlighted,
                  borderRadius: BorderRadius.circular(18),
                  child: _GroupTileWidget(
                    label: tile.label,
                    currentLanguage: settings.currentLanguage,
                    color: color,
                    icon: icon,
                    imagePath: settings.groupImages[tile.label],
                    // In scan mode taps are intercepted by outer GestureDetector
                    onTap: scanOn ? () {} : () => _selectCategory(tile.label),
                  ),
                );
              },
            );

            // ── Row highlight overlay ─────────────────────────────────────
            if (highlightedVocabRow < 0 || !scanOn) return gridWidget;

            // Actual tile height accounts for the grid's top+bottom padding.
            final actualTileHeight =
                (constraints.maxHeight - 2 * padding - (((tiles.length / crossCount).ceil() - 1) * spacing))
                    .clamp(40.0, double.infinity) /
                (tiles.length / crossCount).ceil().clamp(1, 10);
            final rowTop = padding + highlightedVocabRow * (actualTileHeight + spacing);

            return Stack(
              children: [
                gridWidget,
                Positioned(
                  left: 4,
                  right: 4,
                  top: rowTop - 4,
                  height: actualTileHeight + spacing + 8,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kScanHighlightColor,
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        color: kScanHighlightColor.withAlpha(64), // 25% fill
                        boxShadow: [
                          BoxShadow(
                            color: kScanHighlightColor.withAlpha(100),
                            blurRadius: 14,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
    ScanProvider scanProvider,
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

    final baseRows = settings.gridRows.clamp(1, 5);
    final baseCols = settings.gridColumns.clamp(2, 4);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final rows = isPortrait ? math.max(baseRows, baseCols) : math.min(baseRows, baseCols);
    final columns = isPortrait ? math.min(baseRows, baseCols) : math.max(baseRows, baseCols);

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
        final scanOn = scanProvider.isScanModeEnabled;

        // ── Scan highlight state for this grid ────────────────────────────

        // Row highlight: scan row 1..N → vocabRow = scanRow - 1
        final highlightedVocabRow = (scanOn &&
                scanProvider.phase == ScanPhase.row &&
                scanProvider.highlightedRow > 0)
            ? scanProvider.highlightedRow - 1
            : -1;

        // Column highlight
        final isColPhaseVocab = scanOn &&
            scanProvider.phase == ScanPhase.column &&
            scanProvider.selectedRow > 0;
        final selectedVocabRow =
            isColPhaseVocab ? scanProvider.selectedRow - 1 : -1;

        final gridWidget = GridView.builder(
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
            final itemRow = index ~/ columns;
            final itemCol = index % columns;

            final isItemHighlighted = isColPhaseVocab &&
                selectedVocabRow == itemRow &&
                scanProvider.highlightedColumn == itemCol;

            return ScanHighlightOverlay(
              highlighted: isItemHighlighted,
              borderRadius: BorderRadius.circular(12),
              child: VocabularyGridItem(
                item: item,
                iconSize: settings.iconSize,
                showTextLabels: settings.showTextLabels,
                isDark: isDark,
                // AbsorbPointer (ancestor) blocks these taps in scan mode.
                // Normal mode: direct tap adds the word.
                onTap: () async {
                  if (scanOn) return;
                  final messenger = ScaffoldMessenger.of(context);
                  final label = item.getLabel(settings.currentLanguage);
                  final addedPrefix = TranslationService.getBuiltInTranslation(
                      'Added: ', settings.currentLanguage);
                  await communicationProvider.addWordToSentence(item);
                  if (!mounted) return;
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('$addedPrefix$label'),
                      duration: const Duration(milliseconds: 500),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            );
          },
        );

        // ── Row highlight overlay ─────────────────────────────────────────
        if (highlightedVocabRow < 0 || !scanOn) return gridWidget;

        // Use actual rendered tile height: subtract top+bottom grid padding
        // so the overlay lands precisely on the visual row.
        final actualAvailableHeight = math.max(
          gridHeight - 2 * gridPadding - ((rows - 1) * verticalSpacing),
          rows * 48.0,
        );
        final actualTileHeight = actualAvailableHeight / rows;
        final rowTop =
            gridPadding + highlightedVocabRow * (actualTileHeight + verticalSpacing);

        return Stack(
          children: [
            gridWidget,
            Positioned(
              left: 4,
              right: 4,
              top: rowTop - 4,
              height: actualTileHeight + verticalSpacing + 8,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: kScanHighlightColor,
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: kScanHighlightColor.withAlpha(64), // ~25% fill
                    boxShadow: [
                      BoxShadow(
                        color: kScanHighlightColor.withAlpha(100),
                        blurRadius: 14,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
  final String currentLanguage;
  final Color color;
  final IconData icon;
  final String? imagePath;
  final VoidCallback onTap;

  const _GroupTileWidget({
    required this.label,
    required this.currentLanguage,
    required this.color,
    required this.icon,
    this.imagePath,
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
    final translatedLabel = TranslationService.getBuiltInTranslation(
        widget.label, widget.currentLanguage);

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
              if (widget.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: ImageHelper.getImageProvider(widget.imagePath!),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Icon(widget.icon, size: 38, color: Colors.white),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  translatedLabel,
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
