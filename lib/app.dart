import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/views/home_shell.dart';

/// Raíz de la aplicación App Tu Solution.
class AppTuSolutionApp extends StatelessWidget {
  const AppTuSolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Tu Solution',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: const HomeShell(),
    );
  }
}
