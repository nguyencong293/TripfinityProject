import 'package:flutter/material.dart';

class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).progressIndicatorTheme;
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: theme.strokeWidth ?? 2.0,
        color: color ?? theme.color,
      ),
    );
  }
}
