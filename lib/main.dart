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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
