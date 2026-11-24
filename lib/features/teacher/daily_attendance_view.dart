import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';

/// Layar 10 - isi Absen Harian.
class DailyAttendanceView extends StatefulWidget {
  const DailyAttendanceView({super.key});

  @override
  State<DailyAttendanceView> createState() => _DailyAttendanceViewState();
}

class _DailyAttendanceViewState extends State<DailyAttendanceView> {
  DateTime _date = AppState.today;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2026, 7, 1),
      lastDate: AppState.today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _line(StudentRecord s) {
    switch (s.status) {
      case AttStatus.hadir:
      case AttStatus.terlambat:
        return 'Berangkat ${s.checkIn ?? '—'} · Pulang ${s.checkOut ?? '—'}';
      case AttStatus.izin:
        return s.note ?? 'Izin';
      case AttStatus.alpha:
      case AttStatus.belum:
        return 'Tidak ada catatan';
    }
  }

  Widget _photo(String? path, String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: path == null
              ? const Text('Foto contoh\n(belum ada)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted))
              : Image.file(File(path),
                  fit: BoxFit.cover,
                  width: 120,
                  height: 150,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  void _openPhoto(StudentRecord s) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.name),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _photo(s.photoInPath, 'Berangkat'),
            _photo(s.photoOutPath, 'Pulang'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final isDemoDay = sameDay(_date, AppState.today);

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                          '${_date.day} ${monthName(_date.month)} ${_date.year}',
                          style: const TextStyle(fontSize: 14)),
                    ),
                    const Icon(Icons.expand_more, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!isDemoDay)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Data tanggal ini belum tersedia pada versi contoh.\nPilih tanggal hari ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                      child: StatTile(
                          value: '${state.presentCount}', label: 'Hadir')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatTile(
                          value: '${state.count(AttStatus.izin)}',
                          label: 'Izin')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatTile(
                          value: '${state.count(AttStatus.alpha)}',
                          label: 'Alpha')),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    for (var i = 0; i < state.students.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 16, color: AppColors.border),
                      InkWell(
                        onTap: () => _openPhoto(state.students[i]),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('foto',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryDark)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.students[i].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(_line(state.students[i]),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            StatusBadge(
                              state.students[i].status == AttStatus.belum
                                  ? '—'
                                  : state.students[i].status.label,
                              color: state.students[i].status.color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Ketuk baris untuk membuka foto absen.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ],
        );
      },
    );
  }
}
