import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Wraps the main tabs (Today / Library / Quotes / Profile) with a bottom nav.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const tabs = [
    ('/',         'Today',   Icons.today_outlined,     Icons.today),
    ('/library',  'Library', Icons.menu_book_outlined, Icons.menu_book),
    ('/quotes',   'Quotes',  Icons.format_quote_outlined, Icons.format_quote),
    ('/profile',  'Profile', Icons.person_outline,    Icons.person),
  ];

  int get _index {
    if (location.startsWith('/library')) return 1;
    if (location.startsWith('/quotes'))  return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.ink.withValues(alpha: 0.06))),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => context.go(tabs[i].$1),
          items: [
            for (final t in tabs)
              BottomNavigationBarItem(
                icon: Icon(t.$3, size: 22),
                activeIcon: Icon(t.$4, size: 22, color: AppColors.ink),
                label: t.$2,
              ),
          ],
        ),
      ),
    );
  }
}
