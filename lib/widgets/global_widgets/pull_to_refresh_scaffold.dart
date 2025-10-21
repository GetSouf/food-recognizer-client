// lib/widgets/global_widgets/pull_to_refresh_scaffold.dart
import 'package:flutter/material.dart';

class PullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      displacement: 0.0,
      color: theme.primaryColor,
      backgroundColor: theme.cardColor,
      strokeWidth: 3.0,
      onRefresh: onRefresh,
      child: child,
    );
  }
}