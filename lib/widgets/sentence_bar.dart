import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';

class SentenceBar extends StatelessWidget {
  const SentenceBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommunicationProvider, SettingsProvider>(
      builder: (context, communicationProvider, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final words = communicationProvider.currentSentence;
        
        // Debug: Print current sentence length
        debugPrint('SentenceBar rebuild: ${words.length} words');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sentence text display
          Row(
            children: [
              Expanded(
                child: words.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Tap words to build a sentence...',
                          style: TextStyle(
                            fontSize: 18.0 * settings.iconSize,
                            color: Theme.of(context).hintColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            alignment: WrapAlignment.start,
                            children: words.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return _WordChip(
                                key: ValueKey('${item.id}-$index'),
                                word: item.getLabel(settings.currentLanguage),
                                onTap: () {
                                  communicationProvider.removeWordAt(index);
                                },
                                iconSize: settings.iconSize,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          // Action buttons - always show clear button, show others when sentence has words
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sentence summary
              if (words.isNotEmpty)
                Expanded(
                  child: Text(
                    '${words.length} word${words.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 14.0 * settings.iconSize,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (words.isNotEmpty) ...[
                    // Backspace button
                    IconButton(
                      onPressed: () => communicationProvider.removeLastWord(),
                      icon: const Icon(Icons.backspace),
                      tooltip: 'Remove last word',
                      color: Colors.orange,
                    ),
                    // Speak button
                    IconButton(
                      onPressed: () => communicationProvider.speakCurrentSentence(),
                      icon: const Icon(Icons.volume_up),
                      tooltip: 'Speak sentence',
                      color: Colors.green,
                      iconSize: 28,
                    ),
                  ],
                  // Clear button - always visible
                  IconButton(
                    onPressed: () {
                      communicationProvider.clearSentence();
                    },
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear sentence',
                    color: Colors.red,
                    iconSize: 28,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final VoidCallback onTap;
  final double iconSize;

  const _WordChip({
    super.key,
    required this.word,
    required this.onTap,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          word,
          style: TextStyle(fontSize: 16.0 * iconSize, fontWeight: FontWeight.bold),
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onTap,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
      ),
    );
  }
}

