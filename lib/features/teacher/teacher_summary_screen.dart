import 'package:flutter/material.dart';

import '../../core/widgets/app_bottom_nav.dart';
import 'students_tab.dart';
import 'teacher_menu_tab.dart';
import 'teacher_summary_tab.dart';
import 'validation_tab.dart';

/// Kerangka halaman utama wali kelas: bottom nav + 4 tab.
class TeacherSummaryScreen extends StatefulWidget {
  const TeacherSummaryScreen({super.key});

  @override
  State<TeacherSummaryScreen> createState() => _TeacherSummaryScreenState();
}

class _TeacherSummaryScreenState extends State<TeacherSummaryScreen> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.dashboard_outlined, 'Ringkas'),
    NavItem(Icons.groups_outlined, 'Siswa'),
    NavItem(Icons.fact_check_outlined, 'Validasi'),
    NavItem(Icons.menu, 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            TeacherSummaryTab(onOpenValidation: () => setState(() => _index = 2)),
            const StudentsTab(),
            const ValidationTab(),
            const TeacherMenuTab(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          items: _items,
          index: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
