import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../learn/presentation/learn_screen.dart';
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

  static const _screens = <Widget>[
    LearnScreen(),
    WordsScreen(),
    PracticeScreen(),
    DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: _screens),
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
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.teacher),
              selectedIcon: Icon(Iconsax.teacher),
              label: 'Öğren',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.bookmark_2),
              selectedIcon: Icon(Iconsax.bookmark_2),
              label: 'Kelimeler',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.activity),
              selectedIcon: Icon(Iconsax.activity),
              label: 'Pratik',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.discover),
              selectedIcon: Icon(Iconsax.discover),
              label: 'Keşfet',
            ),
          ],
        ),
      ),
    );
  }
}
