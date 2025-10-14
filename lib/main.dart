import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

/// Ponto de entrada do aplicativo
void main() {
  runApp(const ControlePontoApp());
}

/// Widget raiz do aplicativo
class ControlePontoApp extends StatelessWidget {
  const ControlePontoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Ponto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Cores personalizadas
        primaryColor: const Color(0xFF14a25c), // Verde principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14a25c),
          secondary: const Color(0xFFf28b4f), // Laranja secundário
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        
        // Estilo dos botões principais
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14a25c),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Estilo do AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14a25c),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        
        // Estilo dos cards
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
