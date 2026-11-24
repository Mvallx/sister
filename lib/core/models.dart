import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AttStatus { hadir, terlambat, izin, alpha, belum }

extension AttStatusX on AttStatus {
  String get label => switch (this) {
        AttStatus.hadir => 'Hadir',
        AttStatus.terlambat => 'Terlambat',
        AttStatus.izin => 'Izin',
        AttStatus.alpha => 'Alpha',
        AttStatus.belum => 'Belum',
      };

  Color get color => switch (this) {
        AttStatus.hadir => AppColors.hadir,
        AttStatus.terlambat => AppColors.terlambat,
        AttStatus.izin => AppColors.izin,
        AttStatus.alpha => AppColors.alpha,
        AttStatus.belum => AppColors.textMuted,
      };

  bool get isPresent => this == AttStatus.hadir || this == AttStatus.terlambat;
}

enum LeaveType { sakit, keluarga, lomba, lain }

extension LeaveTypeX on LeaveType {
  String get label => switch (this) {
        LeaveType.sakit => 'Sakit',
        LeaveType.keluarga => 'Keluarga',
        LeaveType.lomba => 'Lomba',
        LeaveType.lain => 'Lain',
      };

  String get longLabel => switch (this) {
        LeaveType.sakit => 'Sakit',
        LeaveType.keluarga => 'Keperluan keluarga',
        LeaveType.lomba => 'Lomba',
        LeaveType.lain => 'Lainnya',
      };
}

enum LeaveStatus { menunggu, disetujui, ditolak }

extension LeaveStatusX on LeaveStatus {
  String get label => switch (this) {
        LeaveStatus.menunggu => 'Menunggu',
        LeaveStatus.disetujui => 'Disetujui',
        LeaveStatus.ditolak => 'Ditolak',
      };

  Color get color => switch (this) {
        LeaveStatus.menunggu => AppColors.terlambat,
        LeaveStatus.disetujui => AppColors.hadir,
        LeaveStatus.ditolak => AppColors.alpha,
      };
}

/// Catatan satu siswa pada hari ini (dipakai wali kelas).
class StudentRecord {
  StudentRecord({
    required this.number,
    required this.name,
    required this.nis,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.note,
  });

  final int number;
  final String name;
  final String nis;
  AttStatus status;
  String? checkIn;
  String? checkOut;
  String? note;
  String? photoInPath;
  String? photoOutPath;
  bool missedCheckoutYesterday = false;
}

/// Catatan satu hari di kalender riwayat.
class DayRecord {
  const DayRecord(this.status, this.checkIn, this.checkOut);
  final AttStatus status;
  final String? checkIn;
  final String? checkOut;
}

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.studentName,
    required this.nis,
    required this.type,
    required this.start,
    required this.end,
    required this.reason,
    this.attachmentName,
    this.attachmentPath,
    this.status = LeaveStatus.menunggu,
  });

  final String id;
  final String studentName;
  final String nis;
  final LeaveType type;
  final DateTime start;
  final DateTime end;
  final String reason;
  final String? attachmentName;
  final String? attachmentPath;
  LeaveStatus status;
}
