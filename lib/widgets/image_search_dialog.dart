import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageSearchDialog extends StatefulWidget {
  const ImageSearchDialog({super.key});

  @override
  State<ImageSearchDialog> createState() => _ImageSearchDialogState();
}

class _ImageSearchDialogState extends State<ImageSearchDialog> {
  final _searchController = TextEditingController();
  List<String> _imageUrls = [];
  bool _isLoading = false;
  String? _error;
  bool _isDownloading = false;

  Future<void> _searchImages() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _imageUrls = [];
    });

    try {
      final targetUrl = 'https://images.google.com/search?tbm=isch&q=${Uri.encodeComponent(query)}';
      final url = Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(targetUrl)}');
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      });

      if (response.statusCode == 200) {
        final html = response.body;
        final RegExp exp = RegExp(r'https://encrypted-tbn0\.gstatic\.com/images\?q=tbn:[A-Za-z0-9_-]+');
        final Iterable<RegExpMatch> matches = exp.allMatches(html);
        
        final urls = matches.map((m) => m.group(0)!).toSet().toList();
        
        setState(() {
          _imageUrls = urls;
          if (urls.isEmpty) {
            _error = 'No images found.';
          }
        });
      } else {
        setState(() {
          _error = 'Failed to load images (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error searching images: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndReturnImage(String url) async {
    setState(() {
      _isDownloading = true;
    });
    try {
      final proxiedUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxiedUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/google_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          Navigator.pop(context, path);
        }
      } else {
        setState(() {
          _error = 'Failed to download image';
          _isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error downloading image: $e';
        _isDownloading = false;
      });
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
                      labelText: 'Search Google Images',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchImages(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchImages,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading || _isDownloading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_isDownloading ? 'Downloading Image...' : 'Searching...'),
                    ],
                  ),
                ),
              )
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    final url = _imageUrls[index];
                    return InkWell(
                      onTap: () => _downloadAndReturnImage(url),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
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
