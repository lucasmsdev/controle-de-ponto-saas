import 'package:flutter/material.dart';

/// Serviço para gerenciar o tema (claro/escuro) do app
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  /// Modo escuro ativado
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  /// Alterna entre modo claro e escuro
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Define o modo escuro
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Cores do sistema
  static const Color primaryBlue = Color(0xFF1E3A8A); // Azul escuro
  static const Color primaryBlack = Color(0xFF000000); // Preto
  static const Color primaryWhite = Color(0xFFFFFFFF); // Branco
  static const Color lightGray = Color(0xFFF5F5F5); // Cinza claro
  static const Color mediumGray = Color(0xFF9CA3AF); // Cinza médio
  static const Color darkGray = Color(0xFF1F2937); // Cinza escuro

  /// Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: primaryWhite,
      
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlack,
        surface: primaryWhite,
        background: primaryWhite,
        error: Colors.red,
        onPrimary: primaryWhite,
        onSecondary: primaryWhite,
        onSurface: primaryBlack,
        onBackground: primaryBlack,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: primaryWhite,
        elevation: 0,
        centerTitle: false,
      ),

      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: primaryWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Botões de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
        ),
      ),

      // Botões com borda
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 2,
        color: primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),

      // Divisores
      dividerTheme: const DividerThemeData(
        color: mediumGray,
        thickness: 1,
      ),
    );
  }

  /// Tema escuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: primaryBlack,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryWhite,
        surface: darkGray,
        background: primaryBlack,
        error: Colors.red,
        onPrimary: primaryWhite,
        onSecondary: primaryBlack,
        onSurface: primaryWhite,
        onBackground: primaryWhite,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGray,
        foregroundColor: primaryWhite,
        elevation: 0,
        centerTitle: false,
      ),

      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: primaryWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Botões de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
        ),
      ),

      // Botões com borda
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryWhite,
          side: const BorderSide(color: primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 2,
        color: darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),

      // Divisores
      dividerTheme: const DividerThemeData(
        color: mediumGray,
        thickness: 1,
      ),
    );
  }
}
