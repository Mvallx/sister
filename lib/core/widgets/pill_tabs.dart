import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Deretan pil pilihan (bulan, filter, segmen).
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: i == index ? AppColors.primaryDark : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: i == index ? AppColors.primaryDark : AppColors.border,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: i == index ? Colors.white : AppColors.label,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
