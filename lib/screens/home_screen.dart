import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../providers/communication_provider.dart';
import 'communication_screen.dart';
import 'custom_vocabulary_screen.dart';
import 'settings_screen.dart';
import 'speak_screen.dart';
import 'keyboard_screen.dart';
import 'caregiver_dashboard_screen.dart';

class AwazHomeScreen extends StatefulWidget {
  const AwazHomeScreen({super.key});

  @override
  State<AwazHomeScreen> createState() => _AwazHomeScreenState();
}

class _AwazHomeScreenState extends State<AwazHomeScreen> {
  int _currentIndex = 0;

  List<String> get _tabTitles => [
        translate('tabs.communicate'),
        translate('tabs.speak'),
        translate('tabs.custom'),
        translate('tabs.settings'),
      ];

  List<BottomNavigationBarItem> get _navItems => [
    BottomNavigationBarItem(
      icon: const Icon(Icons.chat_bubble_outline),
      label: translate('tabs.communicate'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.mic),
      label: translate('tabs.speak'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: translate('tabs.custom'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.settings_outlined),
      label: translate('tabs.settings'),
    ),
  ];

  final List<Widget> _pages = const [
    CommunicationScreen(),
    SpeakScreen(),
    CustomVocabularyScreen(),
    SettingsTab(),
  ];

  int get _validIndex => _currentIndex.clamp(0, _pages.length - 1);

  @override
  void initState() {
    super.initState();
    assert(_navItems.length == _pages.length);
    assert(_tabTitles.length == _pages.length);
  }

  void _onNavigationTap(int index) {
    if (index < 0 || index >= _pages.length || _currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _openKeyboard(BuildContext context, CommunicationProvider provider) {
    if (provider.isKeyboardMode) {
      provider.setKeyboardMode(false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KeyboardScreen()),
      );
    }
  }

  void _openCaregiverDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaregiverDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationProvider>(
      builder: (context, communicationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${translate('app_name')} • ${_tabTitles[_validIndex]}'),
            actions: [
              if (_currentIndex == 0)
                IconButton(
                  icon: Icon(communicationProvider.isKeyboardMode
                      ? Icons.grid_view
                      : Icons.keyboard),
                  onPressed: () => _openKeyboard(context, communicationProvider),
                  tooltip: communicationProvider.isKeyboardMode
                      ? 'Switch to Picture Mode'
                      : 'Switch to Keyboard Mode',
                ),
              IconButton(
                icon: const Icon(Icons.dashboard_outlined),
                onPressed: () => _openCaregiverDashboard(context),
                tooltip: 'Caregiver Dashboard',
              ),
            ],
          ),
          body: IndexedStack(
            index: _validIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _validIndex,
            items: _navItems,
            onTap: _onNavigationTap,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}
