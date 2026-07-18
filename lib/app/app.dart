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
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _appState.initialize();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, child) => MaterialApp(
        title: 'Piyasa Radar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _appState.themeMode,
        home: _appState.isInitialized
            ? AppHomePage(appState: _appState)
            : const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
