import 'package:flutter/material.dart';
import 'dart:io';

Widget buildImageFromPath(String imagePath, {double? height, double? width}) {
  return Image.file(
    File(imagePath),
    height: height,
    width: width,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_rounded),
  );
}

class ImageHelper {
  static ImageProvider getImageProvider(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return NetworkImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }
}
