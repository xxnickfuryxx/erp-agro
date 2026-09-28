import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ErpAgroApp());
}

class ErpAgroApp extends StatefulWidget {
  const ErpAgroApp({super.key});

  @override
  State<ErpAgroApp> createState() => _ErpAgroAppState();
}

class _ErpAgroAppState extends State<ErpAgroApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onState);
  }

  @override
  void dispose() {
    _state.removeListener(_onState);
    _state.dispose();
    super.dispose();
  }

  void _onState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Agro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _state.isLoggedIn
          ? AppShell(state: _state)
          : LoginScreen(state: _state),
    );
  }
}
