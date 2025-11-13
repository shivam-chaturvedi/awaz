import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_item.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import 'vocabulary_grid_item.dart';

class FrozenRow extends StatelessWidget {
  final List<VocabularyItem> items;

  const FrozenRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context).settings;
    final communicationProvider = Provider.of<CommunicationProvider>(context);

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100 * settings.iconSize,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 100 * settings.iconSize,
            child: VocabularyGridItem(
              item: item,
              iconSize: settings.iconSize,
              showTextLabels: settings.showTextLabels,
              isDark: Theme.of(context).brightness == Brightness.dark,
              onTap: () => communicationProvider.addWordToSentence(item),
            ),
          );
        },
      ),
    );
  }
}


