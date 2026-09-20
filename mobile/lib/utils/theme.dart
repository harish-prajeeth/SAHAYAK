import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Surakshit premium dark design tokens.
/// Mirrors the web design system: deep navy surfaces, aurora gradients,
/// glass cards and glowing accents.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bg = Color(0xFF0A0E1F);
  static const Color bgDeep = Color(0xFF060915);
  static const Color surface = Color(0xFF121A33);
  static const Color card = Color(0xFF151D3B);
  static const Color border = Color(0x16FFFFFF); // white ~8%

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Brand & accents
  static const Color royal = Color(0xFF1A6BF5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color magenta = Color(0xFFC21DD4);
  static const Color green = Color(0xFF10B981);
  static const Color orange = Color(0xFFF59E0B);
  static const Color amber = Color(0xFFFBBF24);
  static const Color red = Color(0xFFEF4444);
  static const Color cyan = Color(0xFF0EA5E9);
}

class AppGradients {
  AppGradients._();

  /// Signature aurora: blue → violet → magenta (hero banners, primary CTA).
  static const LinearGradient aurora = LinearGradient(
    colors: [Color(0xFF1A6BF5), Color(0xFF7C3AED), Color(0xFFC21DD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent color pairs for badges, stat tiles and avatars.
  static const List<Color> blue = [Color(0xFF2563EB), Color(0xFF3B82F6)];
  static const List<Color> green = [Color(0xFF059669), Color(0xFF10B981)];
  static const List<Color> orange = [Color(0xFFEA580C), Color(0xFFF59E0B)];
  static const List<Color> purple = [Color(0xFF7C3AED), Color(0xFFA855F7)];
  static const List<Color> red = [Color(0xFFDC2626), Color(0xFFEF4444)];
  static const List<Color> cyan = [Color(0xFF0284C7), Color(0xFF0EA5E9)];
  static const List<Color> indigo = [Color(0xFF4F46E5), Color(0xFF818CF8)];

  static LinearGradient of(List<Color> colors) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.royal,
      secondary: AppColors.purple,
      surface: AppColors.surface,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface,
        side: BorderSide(color: AppColors.border),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgDeep,
        indicatorColor: AppColors.blue.withOpacity(0.18),
        surfaceTintColor: Colors.transparent,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
          }
          return const TextStyle(fontSize: 11.5, color: AppColors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.textPrimary);
          }
          return const IconThemeData(color: AppColors.textMuted);
        }),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.bgDeep),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.blue),
      refreshIndicatorTheme: const RefreshIndicatorThemeData(color: AppColors.blue),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700, height: 1.25),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimary, height: 1.45),
        bodyMedium: TextStyle(color: AppColors.textSecondary, height: 1.45),
        bodySmall: TextStyle(color: AppColors.textMuted, height: 1.4),
      ),
    );
  }
}
