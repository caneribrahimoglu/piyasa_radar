import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_home_page.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/core/theme/app_theme.dart';

class PiyasaRadarApp extends StatefulWidget {
  const PiyasaRadarApp({super.key});

  @override
  State<PiyasaRadarApp> createState() => _PiyasaRadarAppState();
}

class _PiyasaRadarAppState extends State<PiyasaRadarApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  void _toggleTheme(Brightness brightness) {
    setState(() {
      final isDark =
          _themeMode == ThemeMode.dark ||
          (_themeMode == ThemeMode.system && brightness == Brightness.dark);
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piyasa Radar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: AppHomePage(appState: _appState, onToggleTheme: _toggleTheme),
    );
  }
}
