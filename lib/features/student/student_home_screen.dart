import 'package:flutter/material.dart';

import '../../core/permission_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
import 'history_tab.dart';
import 'leave_tab.dart';
import 'profile_tab.dart';
import 'student_home_tab.dart';

/// Kerangka halaman utama siswa: bottom nav + 4 tab.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.home_outlined, 'Beranda'),
    NavItem(Icons.event_note_outlined, 'Izin'),
    NavItem(Icons.calendar_month_outlined, 'Riwayat'),
    NavItem(Icons.person_outline, 'Akun'),
  ];

  @override
  void initState() {
    super.initState();
    // Minta izin kamera & lokasi saat siswa pertama kali masuk Beranda.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestAll();
    });
  }

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
            StudentHomeTab(onOpenLeave: () => setState(() => _index = 1)),
            const LeaveTab(),
            const HistoryTab(),
            const ProfileTab(),
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
