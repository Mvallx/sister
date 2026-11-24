import 'package:flutter/material.dart';

import '../app_colors.dart';

class NavItem {
  const NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onChanged,
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.primary.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      height: 64,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon, color: AppColors.textMuted),
            selectedIcon: Icon(item.icon, color: AppColors.primaryDark),
            label: item.label,
          ),
      ],
    );
  }
}
