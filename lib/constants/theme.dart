import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkFantasyTheme {
  // Màu sắc chủ đạo
  static const Color background = Color(0xFF0F0B18);
  static const Color cardBg = Color(0xFF1C1328);
  static const Color stoneBorder = Color(0xFF423456);
  static const Color crimson = Color(0xFF8B0000);
  static const Color bloodRed = Color(0xFFFF3333);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFC5A028);
  static const Color textLight = Color(0xFFE2DCF0);

  // Khung viền góc cạnh Dark Fantasy
  static BoxDecoration gothicBorder({Color borderColor = goldDark}) {
    return BoxDecoration(
      color: cardBg.withValues(alpha: 0.9),
      border: Border.all(color: borderColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: 8,
          offset: const Offset(2, 4),
        ),
      ],
    );
  }

  // Getter themeData áp dụng font VT323 pixel toàn cục
  static ThemeData get themeData {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: gold,
      textTheme: GoogleFonts.vt323TextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textLight,
        displayColor: gold,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        titleTextStyle: GoogleFonts.vt323(
          color: gold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
