
import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';

void main() => runApp(const HadirkuApp());

class HadirkuApp extends StatelessWidget {
  const HadirkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hadirku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash, // cek sesi dulu
      routes: AppRoutes.routes,
    );
  }
}
