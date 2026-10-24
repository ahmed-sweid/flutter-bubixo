import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../learn/presentation/learn_screen.dart';
import '../../learn/presentation/lessons_screen.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../practice/presentation/practice_screen.dart';
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

  void _openPractice() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.canvas,
            surfaceTintColor: Colors.transparent,
            title: const Text('Pratik'),
          ),
          body: const SafeArea(
            top: false,
            child: PracticeScreen(),
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      if (index == 2 && _selectedIndex != 2) _wordsRefreshKey++;
      if (index == 0 && _selectedIndex != 0) _learnRefreshKey++;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      LearnScreen(
        key: ValueKey('learn-$_learnRefreshKey'),
        onOpenDiscover: () => _selectTab(3),
        onOpenWords: () => _selectTab(2),
        onOpenPractice: _openPractice,
        onOpenLessons: () => _selectTab(1),
      ),
      const LessonsScreen(showBackButton: false),
      WordsScreen(key: ValueKey('words-$_wordsRefreshKey')),
      const DiscoverScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
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
            NavigationDestination(
              icon: Icon(Iconsax.teacher),
              label: 'Öğren',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.book_1),
              label: 'Dersler',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.bookmark_2),
              label: 'Kelimeler',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book),
              label: 'Hikâyeler',
            ),
          ],
        ),
      ),
    );
  }
}
