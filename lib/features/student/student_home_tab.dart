import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';
import 'attendance_camera_screen.dart';

/// Layar 02 - Beranda Siswa.
class StudentHomeTab extends StatelessWidget {
  const StudentHomeTab({super.key, required this.onOpenLeave});

  final VoidCallback onOpenLeave;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Pagi';
    if (h < 15) return 'Siang';
    if (h < 18) return 'Sore';
    return 'Malam';
  }

  Future<void> _openCamera(BuildContext context, AttendanceType type) async {
    final msg = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AttendanceCameraScreen(initialType: type),
      ),
    );
    if (msg != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final me = state.me;
        final hasIn = me.checkIn != null && me.status != AttStatus.belum;
        final hasOut = me.checkOut != null;

        final String title = !hasIn
            ? 'Belum absen'
            : hasOut
                ? 'Sudah pulang'
                : 'Sudah berangkat';

        final String actionLabel = !hasIn
            ? 'Foto berangkat'
            : hasOut
                ? 'Absen selesai'
                : 'Foto pulang';

        final VoidCallback? action = hasOut
            ? null
            : () => _openCamera(
                  context,
                  hasIn ? AttendanceType.pulang : AttendanceType.berangkat,
                );

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text(
                '$_greeting, Margana!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'XI RPL · SMK N 1 Bukateja',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              _TodayStatusCard(
                title: title,
                checkIn: me.checkIn,
                checkOut: me.checkOut,
                status: me.status,
              ),
              const SizedBox(height: 12),
              const _WeekCard(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: action,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(actionLabel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onOpenLeave,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Ajukan izin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _ScheduleCard(),
            ],
          ),
        );
      },
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({
    required this.title,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  final String title;
  final String? checkIn;
  final String? checkOut;
  final AttStatus status;

  @override
  Widget build(BuildContext context) {
    final t = AppState.today;
    Widget time(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ],
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dayName(t).toUpperCase()}, ${t.day} ${monthName(t.month).toUpperCase()}',
            style: const TextStyle(
                color: Colors.white60, fontSize: 10, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              time('BERANGKAT', checkIn ?? '—'),
              const SizedBox(width: 32),
              time('PULANG', checkOut ?? '—'),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: status == AttStatus.belum
                      ? Colors.white24
                      : status.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final today = AppState.today;
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    var present = 0;
    var passed = 0;
    final cells = <Widget>[];
    for (var i = 0; i < 6; i++) {
      final d = monday.add(Duration(days: i));
      final isToday = sameDay(d, today);
      final rec = state.dayRecord(d);
      final ok = rec != null && rec.status.isPresent;
      if (i < 5 && !d.isAfter(today)) {
        passed++;
        if (ok) present++;
      }
      final Color bg = isToday
          ? AppColors.primary
          : ok
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.border.withOpacity(0.6);
      final Color fg = isToday ? Colors.white : AppColors.primaryDark;
      cells.add(
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
                const SizedBox(height: 2),
                Text(isToday ? '•' : (ok ? '✓' : '-'),
                    style: TextStyle(fontSize: 12, color: fg)),
              ],
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Minggu ini',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Hadir $present dari $passed hari',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: cells),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  static const _items = <(String, String)>[
    ('Pemrograman Web', '07.00 – 09.30'),
    ('Basis Data', '09.45 – 12.00'),
    ('Bahasa Inggris', '13.00 – 14.30'), // contoh
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jadwal hari ini',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('${_items.length} sesi',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.border),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_items[i].$1,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(_items[i].$2,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
