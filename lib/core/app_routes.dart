import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/student/student_home_screen.dart';
import '../features/teacher/teacher_summary_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const studentHome = '/siswa/beranda'; // Layar 02
  static const teacherSummary = '/wali/ringkasan'; // Layar 08

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    studentHome: (_) => const StudentHomeScreen(),
    teacherSummary: (_) => const TeacherSummaryScreen(),
  };
}
