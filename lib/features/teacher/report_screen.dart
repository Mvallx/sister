import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/widgets/primary_button.dart';

class _MonthReport {
  const _MonthReport(this.label, this.hadir, this.izin, this.alpha,
      this.students, this.days, this.late);
  final String label;
  final int hadir; // persen
  final int izin;
  final int alpha;
  final int students;
  final int days;
  final int late;
}

/// Layar 12 - Laporan Kehadiran (data bulanan contoh).
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _reports = [
    _MonthReport('November 2026', 93, 5, 2, 36, 20, 41),
    _MonthReport('Oktober 2026', 95, 3, 2, 36, 21, 38),
    _MonthReport('September 2026', 94, 4, 2, 36, 22, 33),
  ];

  int _selected = 0;
  bool _exporting = false;

  Future<void> _download(_MonthReport r) async {
    setState(() => _exporting = true);
    try {
      final doc = pw.Document();
      pw.Widget cell(String t, {bool bold = false}) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(t,
                style: pw.TextStyle(
                    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          );
      pw.TableRow row(String a, String b, {bool bold = false}) =>
          pw.TableRow(children: [cell(a, bold: bold), cell(b, bold: bold)]);

      doc.addPage(
        pw.Page(
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Kehadiran Kelas XI RPL',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('SMK N 1 Bukateja - ${r.label}'),
              pw.SizedBox(height: 18),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  row('Keterangan', 'Nilai', bold: true),
                  row('Kehadiran', '${r.hadir}%'),
                  row('Izin', '${r.izin}%'),
                  row('Alpha', '${r.alpha}%'),
                  row('Jumlah siswa', '${r.students} orang'),
                  row('Hari efektif', '${r.days} hari'),
                  row('Terlambat', '${r.late} kali'),
                ],
              ),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'laporan_kehadiran_${r.label.replaceAll(' ', '_')}.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat PDF. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _reports[_selected];

    Widget pct(String label, int v, Color color) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12)),
                  Text('$v%',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: v / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  color: color,
                ),
              ),
            ],
          ),
        );

    Widget detail(String a, String b) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(a, style: const TextStyle(fontSize: 12)),
              Text(b,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const ScreenHeader(
              title: 'Laporan Kehadiran',
              subtitle: 'Rekap bulanan kelas',
              trailing: StatusBadge('WALI KELAS', color: AppColors.alpha),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _selected,
              items: [
                for (var i = 0; i < _reports.length; i++)
                  DropdownMenuItem(value: i, child: Text(_reports[i].label)),
              ],
              onChanged: (v) => setState(() => _selected = v ?? 0),
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Persentase kehadiran',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 12),
                  pct('Hadir', r.hadir, AppColors.hadir),
                  pct('Izin', r.izin, AppColors.izin),
                  pct('Alpha', r.alpha, AppColors.alpha),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rincian',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  detail('Jumlah siswa', '${r.students} orang'),
                  detail('Hari efektif', '${r.days} hari'),
                  detail('Terlambat', '${r.late} kali'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Unduh laporan (PDF)',
              loading: _exporting,
              onPressed: () => _download(r),
            ),
          ],
        ),
      ),
    );
  }
}
