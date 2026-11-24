import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/screen_header.dart';

/// Layar 09 - Daftar Siswa.
class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final _search = TextEditingController();
  int _filter = 0; // 0 semua, 1 hadir, 2 belum

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _subtitle(StudentRecord s) {
    switch (s.status) {
      case AttStatus.hadir:
      case AttStatus.terlambat:
        return 'NIS ${s.nis} · ${s.checkIn ?? '—'}';
      case AttStatus.izin:
        return 'NIS ${s.nis} · ${s.note ?? 'Izin'}';
      case AttStatus.alpha:
        return 'NIS ${s.nis} · tidak ada catatan';
      case AttStatus.belum:
        return 'NIS ${s.nis} · belum absen';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final q = _search.text.trim().toLowerCase();
          final list = state.students.where((s) {
            final okFilter = switch (_filter) {
              1 => s.status.isPresent,
              2 => !s.status.isPresent,
              _ => true,
            };
            final okSearch = q.isEmpty ||
                s.name.toLowerCase().contains(q) ||
                s.nis.contains(q);
            return okFilter && okSearch;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              ScreenHeader(
                title: 'Daftar Siswa',
                subtitle: '${state.totalStudents} siswa · XI RPL',
                trailing: const StatusBadge('WALI KELAS', color: AppColors.alpha),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cari nama / NIS',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              PillTabs(
                labels: const ['Semua', 'Hadir', 'Belum'],
                index: _filter,
                onChanged: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: 12),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Siswa tidak ditemukan.',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                AppCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 16, color: AppColors.border),
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
                              child: Text(
                                list[i].number.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(list[i].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(_subtitle(list[i]),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            StatusBadge(
                              list[i].status == AttStatus.belum
                                  ? '—'
                                  : list[i].status.label,
                              color: list[i].status.color,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
