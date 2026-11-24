import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/widgets/primary_button.dart';

/// Layar 04 - Ajukan Izin.
class LeaveTab extends StatefulWidget {
  const LeaveTab({super.key});

  @override
  State<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends State<LeaveTab> {
  LeaveType _type = LeaveType.sakit;
  late DateTime _start = AppState.today.add(const Duration(days: 1));
  late DateTime _end = _start;
  final _reason = TextEditingController();
  String? _attachName;
  String? _attachPath;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: isStart ? AppState.today : _start,
      lastDate: AppState.today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _pickAttachment() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final f = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (f != null) {
        setState(() {
          _attachName = f.name;
          _attachPath = f.path;
        });
      }
    } catch (_) {
      if (mounted) _snack('Lampiran tidak bisa dibuka di perangkat ini.');
    }
  }

  void _submit() {
    if (_reason.text.trim().length < 5) {
      _snack('Tulis alasan izin dengan jelas (minimal 5 karakter).');
      return;
    }
    AppState.instance.submitLeave(
      type: _type,
      start: _start,
      end: _end,
      reason: _reason.text.trim(),
      attachmentName: _attachName,
      attachmentPath: _attachPath,
    );
    setState(() {
      _reason.clear();
      _attachName = null;
      _attachPath = null;
      _type = LeaveType.sakit;
      _start = AppState.today.add(const Duration(days: 1));
      _end = _start;
    });
    FocusScope.of(context).unfocus();
    _snack('Pengajuan terkirim ke wali kelas.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const ScreenHeader(
            title: 'Ajukan Izin',
            subtitle: 'Isi alasan dan lampirkan bukti',
          ),
          const SizedBox(height: 18),
          const _Label('JENIS'),
          Row(
            children: [
              for (final t in LeaveType.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _type == t ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _type == t
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _type == t ? Colors.white : AppColors.label,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const _Label('TANGGAL'),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  date: _start,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateField(
                  date: _end,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Label('ALASAN'),
          TextField(
            controller: _reason,
            minLines: 3,
            maxLines: 4,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Tulis alasan izin',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          const _Label('LAMPIRAN (SURAT / FOTO)'),
          GestureDetector(
            onTap: _pickAttachment,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: _attachName == null
                  ? const Text('+ Tambah lampiran',
                      style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.attach_file,
                            size: 18, color: AppColors.primaryDark),
                        Flexible(
                          child: Text(_attachName!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() {
                            _attachName = null;
                            _attachPath = null;
                          }),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Kirim pengajuan', onPressed: _submit),
          const SizedBox(height: 12),
          const Text(
            'Status bisa dipantau di menu Akun',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(shortDate(date), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
