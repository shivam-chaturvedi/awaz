import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_item.dart';
import '../utils/color_utils.dart';
import '../services/translation_service.dart';
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
    final detailText = item.labels['detail'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 160.0;
        final labelMaxHeight = showTextLabels
            ? math.min(
                math.min(maxHeight, 56.0),
                math.max(maxHeight * 0.24, 28.0),
              )
            : 0.0;
        final heightScale = math.max(0.7, math.min(1.0, maxHeight / 160.0));
        final adaptiveIconScale = iconSize * heightScale;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              onTap();
            },
            borderRadius: BorderRadius.circular(12.0),
            splashColor: Colors.white.withAlpha(77),
            highlightColor: Colors.white.withAlpha(26),
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
                    color: Colors.black.withAlpha(51),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildImage(adaptiveIconScale),
                    ),
                  ),
                  if (showTextLabels) ...[
                    const SizedBox(height: 2),
                    SizedBox(
                      height: labelMaxHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, _) {
                            final currentLanguage = settingsProvider.settings.currentLanguage;
                            final baseLabel = item.labels['en'] ?? item.labels.values.first;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildLabelText(
                                  baseLabel,
                                  currentLanguage,
                                  textColor,
                                  adaptiveIconScale,
                                ),
                                if ((detailText ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    detailText!,
                                    style: TextStyle(
                                      color: textColor.withAlpha(217),
                                      fontSize: 10 * adaptiveIconScale,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(double adaptiveScale) {
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
          height: 48 * adaptiveScale,
          width: 48 * adaptiveScale,
        );
      }
    } else {
      // Default icon based on category
      return Icon(
        _getIconForCategory(item.category),
        size: 48 * adaptiveScale,
        color: ColorUtils.getTextColorForScheme(item.colorScheme, isDark),
      );
    }
  }

  Widget _buildLabelText(
    String baseLabel,
    String languageCode,
    Color textColor,
    double adaptiveScale,
  ) {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 14 * adaptiveScale,
      fontWeight: FontWeight.bold,
    );

    if (languageCode == 'en' || baseLabel.trim().isEmpty) {
      return Text(
        baseLabel,
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return FutureBuilder<String>(
      future: TranslationService().translate(
        text: baseLabel,
        targetLanguage: languageCode,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            baseLabel,
            style: textStyle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }

        final label = snapshot.data ?? baseLabel;
        return Text(
          label,
          style: textStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
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
