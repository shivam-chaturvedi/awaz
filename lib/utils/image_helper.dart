import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import File only for non-web platforms
import 'dart:io' if (dart.library.html) 'package:awaz/services/file_stub.dart';

Widget buildImageFromPath(String imagePath, {double? height, double? width}) {
  if (kIsWeb) {
    // On web, try to use network image or show placeholder
    return Image.network(
      imagePath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
    );
  } else {
    // On mobile/desktop, use Image.file
    // Cast to dynamic to avoid type checking issues with conditional imports
    return Image.file(
      File(imagePath) as dynamic,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
    );
  }
}
