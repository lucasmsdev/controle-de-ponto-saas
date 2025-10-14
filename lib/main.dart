import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/theme_service.dart';
import 'services/supabase_service.dart';

/// Ponto de entrada do aplicativo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseService.initialize();
  
  runApp(const ControlePontoApp());
}

/// Widget raiz do aplicativo com suporte a tema claro/escuro
class ControlePontoApp extends StatefulWidget {
  const ControlePontoApp({super.key});

  @override
  State<ControlePontoApp> createState() => _ControlePontoAppState();
}

class _ControlePontoAppState extends State<ControlePontoApp> {
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    // Escuta mudanças de tema
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Ponto',
      debugShowCheckedModeBanner: false,
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
