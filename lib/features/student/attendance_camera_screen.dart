import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/location_service.dart';
import '../../core/permission_service.dart';

const _darkBg = Color(0xFF243A2E);

/// Layar 03 - Absen Foto (berangkat / pulang).
/// Menutup dengan pesan sukses (String) bila absen tersimpan.
class AttendanceCameraScreen extends StatefulWidget {
  const AttendanceCameraScreen({super.key, required this.initialType});

  final AttendanceType initialType;

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen> {
  CameraController? _controller;
  String? _error;
  bool _cameraBlocked = false; // izin kamera diblokir permanen
  bool _busy = false;
  LocationCheck? _location;
  late AttendanceType _type = widget.initialType;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _checkLocation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    if (mounted) setState(() => _location = null);
    final loc = await LocationService.check();
    if (mounted) setState(() => _location = loc);
  }

  Future<void> _retryCamera() async {
    setState(() {
      _error = null;
      _cameraBlocked = false;
    });
    await _initCamera();
  }

  Future<void> _initCamera() async {
    final perm = await PermissionService.ensureCamera();
    if (perm != PermState.granted) {
      if (!mounted) return;
      setState(() {
        _cameraBlocked = perm == PermState.permanentlyDenied;
        _error = perm == PermState.permanentlyDenied
            ? 'Izin kamera diblokir. Buka Pengaturan untuk mengaktifkannya.'
            : 'Izin kamera diperlukan untuk absen foto.';
      });
      return;
    }
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) {
          setState(() => _error = 'Kamera tidak ditemukan di perangkat ini.');
        }
        return;
      }
      final cam = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      final c = CameraController(cam, ResolutionPreset.medium,
          enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
    } on CameraException catch (e) {
      if (!mounted) return;
      final denied = e.code.toLowerCase().contains('denied');
      setState(() => _error = denied
          ? 'Izin kamera ditolak. Aktifkan izin kamera di Pengaturan HP.'
          : 'Kamera gagal dibuka (${e.code}).');
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Kamera tidak tersedia di perangkat ini.');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    final loc = _location;
    if (loc == null) {
      _snack('Lokasi masih diperiksa, tunggu sebentar.');
      return;
    }
    if (!loc.canAbsen) {
      _snack(loc.message);
      return;
    }
    setState(() => _busy = true);
    try {
      final file = await c.takePicture();
      final err = AppState.instance.recordAttendance(_type, file.path);
      if (!mounted) return;
      if (err != null) {
        _snack(err);
        setState(() => _busy = false);
        return;
      }
      Navigator.of(context).pop(
        _type == AttendanceType.berangkat
            ? 'Absen berangkat tercatat.'
            : 'Absen pulang tercatat.',
      );
    } on CameraException {
      if (!mounted) return;
      _snack('Gagal mengambil foto, coba lagi.');
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppState.today;
    final now = DateTime.now();
    final loc = _location;

    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Absen Foto',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(
                          '${dayName(t)}, ${shortDate(t)} · ${hm(now)} WIB',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _TypeSwitch(
              type: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Hadapkan wajah ke dalam bingkai',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildPreview()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc?.message ?? 'Memeriksa lokasi...',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (loc != null) _LocationBadge(
                      check: loc,
                      onRetry: _checkLocation,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _capture,
              child: Container(
                width: 72,
                height: 72,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: _busy
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _cameraBlocked
                    ? PermissionService.openSettings
                    : _retryCamera,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: Text(_cameraBlocked ? 'Buka Pengaturan' : 'Coba lagi'),
              ),
              if (_cameraBlocked)
                TextButton(
                  onPressed: _retryCamera,
                  child: const Text('Sudah diaktifkan? Coba lagi',
                      style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    final size = c.value.previewSize;
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              // previewSize berorientasi landscape -> tukar untuk portrait
              width: size?.height ?? 480,
              height: size?.width ?? 640,
              child: CameraPreview(c),
            ),
          ),
        ),
        CustomPaint(painter: _OvalMaskPainter()),
      ],
    );
  }
}

class _TypeSwitch extends StatelessWidget {
  const _TypeSwitch({required this.type, required this.onChanged});

  final AttendanceType type;
  final ValueChanged<AttendanceType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(String label, AttendanceType v) {
      final selected = type == v;
      return GestureDetector(
        onTap: () => onChanged(v),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          item('Berangkat', AttendanceType.berangkat),
          item('Pulang', AttendanceType.pulang),
        ],
      ),
    );
  }
}

class _OvalMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.72;
    final h = (w * 1.3).clamp(0.0, size.height * 0.94);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: w,
      height: h,
    );

    final mask = Path()
      ..addRect(Offset.zero & size)
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(mask, Paint()..color = _darkBg.withOpacity(0.88));

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final oval = Path()..addOval(rect);
    for (final m in oval.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 8), stroke);
        d += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.check, required this.onRetry});

  final LocationCheck check;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    VoidCallback? onTap;

    switch (check.status) {
      case LocationStatus.ready:
      case LocationStatus.simulated:
        label = check.insideSchool ? 'Sesuai' : 'Di luar area';
        color = check.insideSchool ? AppColors.hadir : AppColors.alpha;
        onTap = check.insideSchool ? null : onRetry;
        break;
      case LocationStatus.deniedForever:
        label = 'Pengaturan';
        color = AppColors.alpha;
        onTap = PermissionService.openSettings;
        break;
      default:
        label = 'Coba lagi';
        color = AppColors.alpha;
        onTap = onRetry;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color == AppColors.hadir
                ? AppColors.primaryDark
                : AppColors.error,
          ),
        ),
      ),
    );
  }
}
