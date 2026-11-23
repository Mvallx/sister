import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';

/// Placeholder Layar 02 - Beranda Siswa (dibangun di Tahap 2).
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Siswa'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.login),
          ),
        ],
      ),
      body: const Center(child: Text('Layar 02 · Beranda Siswa')),
    );
  }
}
