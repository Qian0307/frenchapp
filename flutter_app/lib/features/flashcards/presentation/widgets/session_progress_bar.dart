import 'package:flutter/material.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({super.key, required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    return LinearProgressIndicator(
      value:            progress,
      minHeight:        4,
      backgroundColor:  Colors.transparent,
      valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
    );
  }
}
