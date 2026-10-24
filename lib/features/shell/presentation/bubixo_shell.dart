import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/database/database_bootstrap.dart';
import '../../../core/theme/tokens/app_colors.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../learn/presentation/learn_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../words/data/legacy_words_migration.dart';
import '../../words/presentation/words_screen.dart';

/// The top-level navigation shell. IndexedStack preserves each tab's state
/// when the user switches between destinations.
class BubixoShell extends StatefulWidget {
  const BubixoShell({super.key});

  @override
  State<BubixoShell> createState() => _BubixoShellState();
}

class _BubixoShellState extends State<BubixoShell> {
  int _selectedIndex = 0;
  int _wordsRefreshKey = 0;
  int _learnRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _migrateLegacyWords();
  }

  /// Copies pre-database word lists once, before any tab reads the
  /// collection, so progress shown elsewhere matches the saved words.
  void _migrateLegacyWords() {
    if (!DatabaseBootstrap.isSupportedPlatform) return;
    unawaited(
      DatabaseBootstrap.initialize()
          .then<void>((database) => const LegacyWordsMigration().run(database))
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint('Bubixo legacy word migration failed: $error');
            debugPrintStack(stackTrace: stackTrace);
          }),
    );
  }

  void _selectTab(int index) {
    setState(() {
      if (index == 1 && _selectedIndex != 1) _wordsRefreshKey++;
      if (index == 0 && _selectedIndex != 0) _learnRefreshKey++;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      LearnScreen(
        key: ValueKey('learn-$_learnRefreshKey'),
        onOpenWords: () => _selectTab(1),
        onOpenStories: () => _selectTab(2),
        onOpenPractice: () => _selectTab(3),
      ),
      WordsScreen(key: ValueKey('words-$_wordsRefreshKey')),
      const DiscoverScreen(),
      const PracticeScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.canvas,
          indicatorColor: AppColors.hairline,
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.ink : AppColors.bodyMid,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.teacher), label: 'Öğren'),
            NavigationDestination(
              icon: Icon(Iconsax.bookmark_2),
              label: 'Kelimeler',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.book_1),
              label: 'Hikâyeler',
            ),
            NavigationDestination(icon: Icon(Iconsax.flash_1), label: 'Pratik'),
          ],
        ),
      ),
    );
  }
}
