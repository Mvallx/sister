import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/screen_header.dart';

/// Layar 05 (Riwayat kalender) dan Layar 06 (Statistik) dalam satu tab.
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  int _segment = 0; // 0 = Kalender, 1 = Statistik
  int _month = 0;

  static const _months = [(2026, 11), (2026, 10), (2026, 9)];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            ScreenHeader(
              title: _segment == 0 ? 'Riwayat' : 'Statistikku',
              subtitle: _segment == 0
                  ? 'Kalender kehadiranmu'
                  : 'Ringkasan kehadiran semester ini',
            ),
            const SizedBox(height: 12),
            PillTabs(
              labels: const ['Kalender', 'Statistik'],
              index: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
            const SizedBox(height: 14),
            if (_segment == 0) ...[
              PillTabs(
                labels: [for (final m in _months) monthName(m.$2)],
                index: _month,
                onChanged: (i) => setState(() => _month = i),
              ),
              const SizedBox(height: 12),
              _CalendarCard(year: _months[_month].$1, month: _months[_month].$2),
              const SizedBox(height: 12),
              _RecentDays(year: _months[_month].$1, month: _months[_month].$2),
            ] else
              const _StatsView(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Kalender ----------------
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.year, required this.month});
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final offset = DateTime(year, month, 1).weekday - 1; // Senin = 0
    final days = DateTime(year, month + 1, 0).day;
    const head = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    final cells = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var day = 1; day <= days; day++)
        _DayCell(
          day: day,
          record: state.dayRecord(DateTime(year, month, day)),
        ),
    ];

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              for (final h in head)
                Expanded(
                  child: Center(
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            children: cells,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            children: [
              for (final s in [
                AttStatus.hadir,
                AttStatus.terlambat,
                AttStatus.izin,
                AttStatus.alpha,
              ])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(s.label,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.record});
  final int day;
  final DayRecord? record;

  @override
  Widget build(BuildContext context) {
    final r = record;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: r == null ? AppColors.border.withOpacity(0.5) : r.status.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: r == null ? AppColors.textMuted : Colors.white,
        ),
      ),
    );
  }
}

class _RecentDays extends StatelessWidget {
  const _RecentDays({required this.year, required this.month});
  final int year;
  final int month;

  String _subtitle(DayRecord r) {
    switch (r.status) {
      case AttStatus.hadir:
        return 'Tepat waktu';
      case AttStatus.terlambat:
        final p = (r.checkIn ?? '07.00').split('.');
        final mins = int.parse(p[0]) * 60 +
            int.parse(p[1]) -
            (AppState.lateHour * 60 + AppState.lateMinute);
        return 'Lewat $mins menit';
      case AttStatus.izin:
        return 'Izin disetujui';
      case AttStatus.alpha:
        return 'Tanpa keterangan';
      case AttStatus.belum:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final last = DateTime(year, month + 1, 0);
    var d = last.isAfter(AppState.today) ? AppState.today : last;
    final found = <(DateTime, DayRecord)>[];
    while (d.month == month && found.length < 3) {
      final r = state.dayRecord(d);
      if (r != null) found.add((d, r));
      d = d.subtract(const Duration(days: 1));
    }

    if (found.isEmpty) {
      return const AppCard(
        child: Text('Belum ada catatan bulan ini.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      );
    }

    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < found.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.border),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${found[i].$1.day}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        found[i].$2.checkIn == null
                            ? dayName(found[i].$1)
                            : '${dayName(found[i].$1)} · ${found[i].$2.checkIn} – ${found[i].$2.checkOut ?? '—'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(_subtitle(found[i].$2),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                StatusBadge(found[i].$2.status.label,
                    color: found[i].$2.status.color),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------- Statistik ----------------
class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    const eff = AppState.semesterEffective;
    const hadir = AppState.semesterHadir;
    final pct = (hadir / eff * 100).round();

    Widget bar(String label, int value) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12)),
                  Text('$value%',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('KEHADIRAN SEMESTER INI',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('$pct%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text('$hadir HARI HADIR DARI $eff HARI EFEKTIF',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
                child: StatTile(
                    value: '${AppState.semesterHadir}', label: 'Hadir')),
            SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    value: '${AppState.semesterTerlambat}',
                    label: 'Terlambat')),
            SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    value: '${AppState.semesterIzin}', label: 'Izin')),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kelas XI RPL minggu ini',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 12),
              bar('Kehadiran kelas', AppState.classAttendance),
              bar('Ketepatan waktu', AppState.classPunctuality),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ketepatan waktu mingguan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0;
                        i < AppState.weeklyPunctuality.length;
                        i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${AppState.weeklyPunctuality[i]}%',
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Container(
                              height:
                                  70 * AppState.weeklyPunctuality[i] / 100,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('M${i + 1}',
                                style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
