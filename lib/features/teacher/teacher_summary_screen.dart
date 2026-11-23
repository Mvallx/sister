import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';

/// Placeholder Layar 08 - Ringkasan Wali Kelas (dibangun di Tahap 6).
class TeacherSummaryScreen extends StatelessWidget {
  const TeacherSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Kelas'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.login),
          ),
        ],
      ),
      body: const Center(child: Text('Layar 08 · Ringkasan Wali Kelas')),
    );
  }
}
