import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/screen_header.dart';
import 'daily_attendance_view.dart';
import 'leave_requests_view.dart';

/// Tab Validasi: Pengajuan Izin (Layar 11) dan Absen Harian (Layar 10).
class ValidationTab extends StatefulWidget {
  const ValidationTab({super.key});

  @override
  State<ValidationTab> createState() => _ValidationTabState();
}

class _ValidationTabState extends State<ValidationTab> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          ScreenHeader(
            title: _segment == 0 ? 'Pengajuan Izin' : 'Absen Harian',
            subtitle: _segment == 0
                ? 'Setujui atau tolak'
                : 'Pilih tanggal dan periksa foto',
            trailing: const StatusBadge('WALI KELAS', color: AppColors.alpha),
          ),
          const SizedBox(height: 12),
          PillTabs(
            labels: const ['Pengajuan Izin', 'Absen Harian'],
            index: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
          const SizedBox(height: 14),
          if (_segment == 0)
            const LeaveRequestsView()
          else
            const DailyAttendanceView(),
        ],
      ),
    );
  }
}
