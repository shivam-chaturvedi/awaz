import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageSearchDialog extends StatefulWidget {
  const ImageSearchDialog({super.key});

  @override
  State<ImageSearchDialog> createState() => _ImageSearchDialogState();
}

class _ImageSearchDialogState extends State<ImageSearchDialog> {
  final _searchController = TextEditingController();
  List<_SearchImage> _images = [];
  bool _isLoading = false;
  String? _error;
  bool _isDownloading = false;

  static const _userAgent = 'ChinnamAAC/1.0 (educational AAC app)';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchImages() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _images = [];
    });

    try {
      // Wikimedia Commons is free, keyless, and reliable on device.
      // (Direct Google HTML scraping is blocked; Openverse now requires auth.)
      final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'format': 'json',
        'origin': '*',
        'generator': 'search',
        'gsrnamespace': '6',
        'gsrlimit': '24',
        'gsrsearch': query,
        'prop': 'imageinfo',
        'iiprop': 'url|mime|size',
        'iiurlwidth': '400',
      });

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode != 200) {
        setState(() {
          _error = 'Failed to load images (${response.statusCode})';
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final pages =
          (data['query'] as Map<String, dynamic>?)?['pages'] as Map<String, dynamic>? ??
              {};

      final results = <_SearchImage>[];
      for (final page in pages.values.whereType<Map<String, dynamic>>()) {
        final infos = page['imageinfo'];
        if (infos is! List || infos.isEmpty) continue;
        final info = infos.first;
        if (info is! Map<String, dynamic>) continue;

        final mime = (info['mime'] as String?) ?? '';
        if (!mime.startsWith('image/')) continue;

        final thumb = (info['thumburl'] as String?)?.trim() ?? '';
        final full = (info['url'] as String?)?.trim() ?? '';
        if (thumb.isEmpty && full.isEmpty) continue;

        results.add(
          _SearchImage(
            previewUrl: thumb.isNotEmpty ? thumb : full,
            downloadUrl: full.isNotEmpty ? full : thumb,
            title: (page['title'] as String?) ?? '',
          ),
        );
      }

      setState(() {
        _images = results;
        if (results.isEmpty) {
          _error = 'No images found. Try a different search.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error searching images: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadAndReturnImage(_SearchImage image) async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });
    try {
      var response = await http.get(
        Uri.parse(image.downloadUrl),
        headers: const {'User-Agent': _userAgent},
      );
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        response = await http.get(
          Uri.parse(image.previewUrl),
          headers: const {'User-Agent': _userAgent},
        );
      }
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        setState(() {
          _error = 'Failed to download image';
          _isDownloading = false;
        });
        return;
      }
      await _saveAndPop(response.bodyBytes);
    } catch (e) {
      setState(() {
        _error = 'Error downloading image: $e';
        _isDownloading = false;
      });
    }
  }

  Future<void> _saveAndPop(List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/web_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(bytes, flush: true);
    if (mounted) {
      Navigator.pop(context, path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search images online',
                      hintText: 'e.g. apple, water, school bus',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchImages(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading || _isDownloading ? null : _searchImages,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Tap an image to import it into the tile',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading || _isDownloading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_isDownloading ? 'Downloading image...' : 'Searching...'),
                    ],
                  ),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    return InkWell(
                      onTap: () => _downloadAndReturnImage(image),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image.previewUrl,
                          fit: BoxFit.cover,
                          headers: const {'User-Agent': _userAgent},
                          errorBuilder: (context, error, stackTrace) =>
                              const ColoredBox(
                            color: Color(0xFFE0E0E0),
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchImage {
  final String previewUrl;
  final String downloadUrl;
  final String title;

  const _SearchImage({
    required this.previewUrl,
    required this.downloadUrl,
    required this.title,
  });
}
