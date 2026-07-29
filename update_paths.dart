import 'dart:io';

void main() {
  final file = File('lib/services/vocabulary_initializer.dart');
  var content = file.readAsStringSync();
  
  final regex = RegExp(r"VocabularyItem\([^)]+labels:\s*\{'en':\s*'([^']+)'\}[^)]+\)");
  
  final matches = regex.allMatches(content).toList();
  for (var match in matches) {
    final block = match.group(0)!;
    final label = match.group(1)!;
    if (!block.contains('imagePath:')) {
      final replacement = block.replaceFirst(
        'id: _uuid.v4(),', 
        "id: _uuid.v4(),\n        imagePath: 'assets/images/${label.replaceAll(' ', '_')}.jpg',"
      );
      content = content.replaceAll(block, replacement);
    }
  }
  
  file.writeAsStringSync(content);
}
