import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/theme_service.dart';
import 'services/supabase_service.dart';

/// Ponto de entrada do aplicativo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseService.initialize();
    runApp(const ControlePontoApp());
  } catch (e) {
    print('Erro ao inicializar app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

/// App de erro caso a inicialização falhe
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Erro ao Inicializar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
