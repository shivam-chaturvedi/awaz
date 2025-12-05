import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../widgets/sentence_bar.dart';

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communicationProvider = Provider.of<CommunicationProvider>(context);
    final settings = Provider.of<SettingsProvider>(context).settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SentenceBar(),
          Expanded(
            child: Column(
              children: [
                // Text input field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    autofocus: true,
                    style: TextStyle(fontSize: 24.0 * settings.iconSize),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            communicationProvider.addTextToSentence(text);
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        communicationProvider.addTextToSentence(text.trim());
                        _textController.clear();
                      }
                    },
                  ),
                ),
                
                // Recent words suggestions
                if (communicationProvider.currentSentence.isNotEmpty)
                  _buildRecentWords(communicationProvider, settings),
                
                // Virtual keyboard (optional - system keyboard is preferred)
                Expanded(
                  child: _buildVirtualKeyboard(communicationProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWords(
    CommunicationProvider communicationProvider,
    AppSettings settings,
  ) {
    final recentWords = communicationProvider.currentSentence
        .map((item) => item.getLabel(settings.currentLanguage))
        .toSet()
        .toList()
        .reversed
        .take(settings.maxRecentWords)
        .toList();

    if (recentWords.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentWords.length,
        itemBuilder: (context, index) {
          final word = recentWords[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              label: Text(word),
              onDeleted: () {
                // Add word to sentence
                communicationProvider.addTextToSentence(word);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVirtualKeyboard(CommunicationProvider communicationProvider) {
    // Simple virtual keyboard layout
    return GridView.count(
      crossAxisCount: 10,
      padding: const EdgeInsets.all(8.0),
      children: [
        ..._buildKeyboardRow('QWERTYUIOP', communicationProvider),
        ..._buildKeyboardRow('ASDFGHJKL', communicationProvider),
        ..._buildKeyboardRow('ZXCVBNM', communicationProvider),
        _buildKey('Space', () {
          communicationProvider.addTextToSentence(' ');
        }, isLarge: true),
        _buildKey('Backspace', () {
          communicationProvider.removeLastWord();
        }),
      ],
    );
  }

  List<Widget> _buildKeyboardRow(
    String letters,
    CommunicationProvider communicationProvider,
  ) {
    return letters.split('').map((char) {
      return _buildKey(char, () {
        communicationProvider.addTextToSentence(char);
      });
    }).toList();
  }

  Widget _buildKey(String label, VoidCallback onTap, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(isLarge ? 16.0 : 8.0),
        ),
        child: Text(label),
      ),
    );
  }
}
