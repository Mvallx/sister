import 'package:flutter/foundation.dart';

import 'date_utils.dart';
import 'models.dart';

enum AttendanceType { berangkat, pulang }

/// Penyimpanan data SEMENTARA di memori (simulasi backend).
/// Siswa dan wali kelas berbagi data ini, jadi alurnya bisa diuji di satu HP.
/// Saat REST API siap, pecah menjadi repository + panggilan jaringan.
class AppState extends ChangeNotifier {
  AppState._() {
    _seed();
  }
  static final AppState instance = AppState._();

  /// Tanggal contoh sesuai desain. Ganti ke DateTime.now() saat data nyata.
  static final DateTime today = DateTime(2026, 11, 16);

  static const lateHour = 7; // batas jam masuk (sesuaikan aturan sekolah)
  static const lateMinute = 0;

  static const studentNis = '12316';
  static const studentName = 'Margana Valdis';
  static const studentNumber = 16;

  // Statistik semester & kelas (contoh)
  static const semesterEffective = 83;
  static const semesterHadir = 78;
  static const semesterTerlambat = 3;
  static const semesterIzin = 2;
  static const classAttendance = 94;
  static const classPunctuality = 89;
  static const weeklyPunctuality = [100, 80, 100, 100, 100];

  final List<StudentRecord> students = [];
  final List<LeaveRequest> leaves = [];
  final Map<String, DayRecord> _history = {};

  StudentRecord get me => students[studentNumber - 1];

  // ---------- seed ----------
  void _seed() {
    students.clear();
    leaves.clear();
    _history.clear();

    const late = {3: '07.14', 12: '07.12', 25: '07.20'};
    for (var i = 1; i <= 36; i++) {
      final r = StudentRecord(
        number: i,
        name: i == studentNumber ? studentName : 'Nama Siswa ${two(i)}',
        nis: '123${two(i)}',
        status: AttStatus.hadir,
        checkIn: '06.${two(30 + (i * 7) % 25)}',
      );
      if (late.containsKey(i)) {
        r.status = AttStatus.terlambat;
        r.checkIn = late[i];
      }
      students.add(r);
    }
    students[3]
      ..status = AttStatus.izin
      ..checkIn = null
      ..note = 'Izin sakit';
    students[5]
      ..status = AttStatus.alpha
      ..checkIn = null;
    me.checkIn = '06.41';
    students[21].missedCheckoutYesterday = true;

    LeaveRequest l(String id, int no, LeaveType t, DateTime s, DateTime e,
            String reason, LeaveStatus st, [String? file]) =>
        LeaveRequest(
          id: id,
          studentName: 'Nama Siswa ${two(no)}',
          nis: '123${two(no)}',
          type: t,
          start: s,
          end: e,
          reason: reason,
          attachmentName: file,
          status: st,
        );
    leaves.addAll([
      l('L1', 7, LeaveType.sakit, DateTime(2026, 11, 17), DateTime(2026, 11, 18),
          'Demam dan disarankan istirahat dua hari oleh dokter.',
          LeaveStatus.menunggu, 'surat_dokter.jpg'),
      l('L2', 14, LeaveType.keluarga, DateTime(2026, 11, 10),
          DateTime(2026, 11, 10), 'Menghadiri acara keluarga.',
          LeaveStatus.disetujui),
      l('L3', 2, LeaveType.sakit, DateTime(2026, 11, 2), DateTime(2026, 11, 2),
          'Sakit perut.', LeaveStatus.disetujui),
      l('L4', 9, LeaveType.lomba, DateTime(2026, 11, 4), DateTime(2026, 11, 5),
          'Mewakili sekolah lomba LKS.', LeaveStatus.disetujui),
      l('L5', 18, LeaveType.sakit, DateTime(2026, 10, 28),
          DateTime(2026, 10, 28), 'Flu.', LeaveStatus.disetujui),
      l('L6', 30, LeaveType.keluarga, DateTime(2026, 10, 20),
          DateTime(2026, 10, 20), 'Keperluan keluarga.', LeaveStatus.disetujui),
    ]);

    var d = DateTime(2026, 9, 1);
    while (!d.isAfter(DateTime(2026, 11, 13))) {
      if (d.weekday <= 5) {
        _history[dateKey(d)] = DayRecord(
            AttStatus.hadir, '06.${two(30 + (d.day * 7) % 25)}', '15.30');
      }
      d = d.add(const Duration(days: 1));
    }
    void ex(int m, int day, AttStatus s, [String? i, String? o]) =>
        _history[dateKey(DateTime(2026, m, day))] = DayRecord(s, i, o);
    ex(9, 8, AttStatus.terlambat, '07.05', '15.30');
    ex(9, 22, AttStatus.izin);
    ex(10, 6, AttStatus.terlambat, '07.09', '15.30');
    ex(10, 14, AttStatus.alpha);
    ex(10, 20, AttStatus.izin);
    ex(11, 3, AttStatus.terlambat, '07.08', '15.30');
    ex(11, 5, AttStatus.izin);
    ex(11, 10, AttStatus.alpha);
    ex(11, 12, AttStatus.terlambat, '07.12', '15.31');
    ex(11, 13, AttStatus.hadir, '06.38', '15.30');
  }

  // ---------- query ----------
  DayRecord? dayRecord(DateTime d) {
    if (sameDay(d, today)) {
      final m = me;
      if (m.status == AttStatus.belum) return null;
      return DayRecord(m.status, m.checkIn, m.checkOut);
    }
    return _history[dateKey(d)];
  }

  int count(AttStatus s) => students.where((x) => x.status == s).length;
  int get presentCount => students.where((x) => x.status.isPresent).length;
  int get totalStudents => students.length;

  List<LeaveRequest> get myLeaves =>
      leaves.where((l) => l.nis == studentNis).toList();
  int get myPendingCount =>
      myLeaves.where((l) => l.status == LeaveStatus.menunggu).length;
  int leaveCount(LeaveStatus s) => leaves.where((l) => l.status == s).length;

  // ---------- siswa: absen ----------
  /// Mengembalikan pesan error, atau null bila berhasil.
  String? recordAttendance(AttendanceType type, String photoPath) {
    final now = DateTime.now();
    final m = me;
    if (type == AttendanceType.berangkat) {
      if (m.checkIn != null && m.status != AttStatus.belum) {
        return 'Kamu sudah absen berangkat hari ini.';
      }
      m.checkIn = hm(now);
      m.photoInPath = photoPath;
      final late = now.hour * 60 + now.minute > lateHour * 60 + lateMinute;
      m.status = late ? AttStatus.terlambat : AttStatus.hadir;
    } else {
      if (m.checkIn == null || m.status == AttStatus.belum) {
        return 'Absen berangkat dulu sebelum absen pulang.';
      }
      if (m.checkOut != null) return 'Kamu sudah absen pulang hari ini.';
      m.checkOut = hm(now);
      m.photoOutPath = photoPath;
    }
    notifyListeners();
    return null;
  }

  // ---------- siswa: izin ----------
  void submitLeave({
    required LeaveType type,
    required DateTime start,
    required DateTime end,
    required String reason,
    String? attachmentName,
    String? attachmentPath,
  }) {
    leaves.insert(
      0,
      LeaveRequest(
        id: 'L${leaves.length + 1}',
        studentName: studentName,
        nis: studentNis,
        type: type,
        start: start,
        end: end,
        reason: reason,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
      ),
    );
    notifyListeners();
  }

  // ---------- wali kelas: validasi ----------
  void decideLeave(LeaveRequest l, {required bool approve}) {
    l.status = approve ? LeaveStatus.disetujui : LeaveStatus.ditolak;
    // Izin yang disetujui masuk rekap; yang ditolak tidak mengubah status.
    if (approve) {
      final covers = !AppState.today.isBefore(
              DateTime(l.start.year, l.start.month, l.start.day)) &&
          !AppState.today.isAfter(DateTime(l.end.year, l.end.month, l.end.day));
      if (covers) {
        final r = students.firstWhere((s) => s.nis == l.nis);
        if (!r.status.isPresent) {
          r.status = AttStatus.izin;
          r.note = 'Izin ${l.type.longLabel.toLowerCase()}';
        }
      }
    }
    notifyListeners();
  }

  // ---------- uji coba ----------
  void clearMyToday() {
    final m = me;
    m.status = AttStatus.belum;
    m.checkIn = null;
    m.checkOut = null;
    m.photoInPath = null;
    m.photoOutPath = null;
    notifyListeners();
  }

  void resetAll() {
    _seed();
    notifyListeners();
  }
}
