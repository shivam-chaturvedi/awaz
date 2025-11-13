import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/vocabulary_item.dart';
import '../utils/color_utils.dart';
import '../utils/image_helper.dart';
import '../providers/settings_provider.dart';

class VocabularyGridItem extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback onTap;
  final double iconSize;
  final bool showTextLabels;
  final bool isDark;

  const VocabularyGridItem({
    super.key,
    required this.item,
    required this.onTap,
    this.iconSize = 1.0,
    this.showTextLabels = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.getColorForScheme(item.colorScheme);
    final textColor = ColorUtils.getTextColorForScheme(item.colorScheme, isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          onTap();
        },
        borderRadius: BorderRadius.circular(12.0),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark ? Colors.white : Colors.black,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildImage(),
              ),
            ),
            if (showTextLabels)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                  child: Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, _) {
                      return Text(
                        item.getLabel(settingsProvider.settings.currentLanguage),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12 * iconSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (item.imagePath != null) {
      // Local image
      if (item.imagePath!.startsWith('assets/')) {
        return Image.asset(
          item.imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
        );
      } else {
        // File path - use helper for platform-specific image loading
        return buildImageFromPath(
          item.imagePath!,
          height: 48 * iconSize,
          width: 48 * iconSize,
        );
      }
    } else {
      // Default icon based on category
      return Icon(
        _getIconForCategory(item.category),
        size: 48 * iconSize,
        color: ColorUtils.getTextColorForScheme(item.colorScheme, isDark),
      );
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'QUICK':
        return Icons.chat_bubble;
      case 'QUESTIONS':
        return Icons.help;
      case 'PEOPLE':
        return Icons.people;
      case 'ACTIONS':
        return Icons.directions_run;
      case 'FEELINGS':
        return Icons.sentiment_satisfied;
      case 'TIME':
        return Icons.access_time;
      case 'PLACES':
        return Icons.place;
      case 'FOOD':
        return Icons.restaurant;
      case 'ANIMALS':
        return Icons.pets;
      case 'CLOTHES':
        return Icons.checkroom;
      case 'BODY PARTS':
        return Icons.face;
      default:
        return Icons.tag;
    }
  }
}

