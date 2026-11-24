import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

/// Logo Hadirku (dipakai di Login dan Splash).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icon/logo.png',
          width: size,
          height: size,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 12),
        const Text(
          'Hadirku',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
