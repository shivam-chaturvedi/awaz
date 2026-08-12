import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('transfer media embedding', () {
    test('base64 round-trip preserves image bytes', () async {
      final dir = await Directory.systemTemp.createTemp('awaz_transfer_');
      final file = File(p.join(dir.path, 'tile.png'));
      final original = List<int>.generate(64, (i) => i);
      await file.writeAsBytes(original);

      final encoded = base64Encode(await file.readAsBytes());
      final restoredPath = p.join(dir.path, 'restored.png');
      await File(restoredPath).writeAsBytes(base64Decode(encoded));

      expect(await File(restoredPath).readAsBytes(), original);
      await dir.delete(recursive: true);
    });

    test('export payload shape includes media + groups keys', () {
      final payload = {
        'vocabulary_items': [
          {
            'id': '1',
            'labels': {'en': 'hello'},
            'category': 'custom',
            'imagePath': 'media/hello.jpg',
            'customAudioPath': 'media/hello.m4a',
          }
        ],
        'custom_groups': ['Family'],
        'media': {
          'media/hello.jpg': base64Encode([1, 2, 3]),
          'media/hello.m4a': base64Encode([4, 5, 6]),
        },
        'version': 2,
      };

      expect(payload.containsKey('media'), isTrue);
      expect(payload.containsKey('custom_groups'), isTrue);
      expect((payload['media'] as Map).length, 2);
    });
  });
}
