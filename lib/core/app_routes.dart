import 'package:flutter/material.dart';

import '../features/auth/auth_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/student/student_home_screen.dart';
import '../features/teacher/teacher_summary_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const studentHome = '/siswa/beranda'; // Layar 02
  static const teacherSummary = '/wali/ringkasan'; // Layar 08

  static String homeFor(UserRole role) =>
      role == UserRole.siswa ? studentHome : teacherSummary;

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    studentHome: (_) => const StudentHomeScreen(),
    teacherSummary: (_) => const TeacherSummaryScreen(),
  };
}
