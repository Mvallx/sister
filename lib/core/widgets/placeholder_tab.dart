import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Penanda untuk tab yang layarnya belum dibuat.
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          '$title\n(segera dibuat)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
