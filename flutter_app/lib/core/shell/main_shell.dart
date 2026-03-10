import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell shared by all main screens.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    ('/dashboard', Icons.home_rounded,          Icons.home_outlined,      'Home'),
    ('/flashcards',Icons.style_rounded,         Icons.style_outlined,     'Cards'),
    ('/articles',  Icons.auto_stories_rounded,  Icons.auto_stories_outlined,'Read'),
    ('/grammar',   Icons.school_rounded,        Icons.school_outlined,    'Grammar'),
    ('/mistakes',  Icons.edit_note_rounded,     Icons.edit_note_outlined, 'Mistakes'),
  ];

  int _locationToIndex(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i != currentIndex) context.go(_tabs[i].$1);
        },
        destinations: _tabs.map((t) => NavigationDestination(
          icon:         Icon(t.$3),
          selectedIcon: Icon(t.$2),
          label:        t.$4,
        )).toList(),
      ),
    );
  }
}
