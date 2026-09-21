import 'package:flutter/material.dart';

/// The blue highlight colour used for all scan-mode visual indicators.
const Color kScanHighlightColor = Color(0xFF1565C0); // Blue 800 — bold and visible

/// Wraps [child] with a thick glowing blue border when [highlighted] is `true`.
///
/// Used for every scan-mode visual highlight: row outlines, column item
/// outlines, and individual top-control button highlights.
class ScanHighlightOverlay extends StatelessWidget {
  final Widget child;
  final bool highlighted;
  final BorderRadius borderRadius;
  final double borderWidth;

  const ScanHighlightOverlay({
    super.key,
    required this.child,
    required this.highlighted,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.borderWidth = 4.0, // thicker default for visibility
  });

  @override
  Widget build(BuildContext context) {
    if (!highlighted) return child;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: kScanHighlightColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: kScanHighlightColor.withAlpha(120), // strong outer glow
            blurRadius: 16,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: kScanHighlightColor.withAlpha(60),  // softer halo
            blurRadius: 28,
            spreadRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
