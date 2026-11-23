import 'package:flutter/material.dart';

/// Token warna Tamajiwa: krem hangat, tinta hitam, dan aksen lime.
class AppColors {
  AppColors._();

  static const lime = Color(0xFFE3F21B);
  static const limeSoft = Color(0xFFF1F8A8);
  static const ink = Color(0xFF111110);
  static const cream = Color(0xFFF2F1E9);
  static const creamDeep = Color(0xFFE6E4D6);
  static const card = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6D6C63);
  static const line = Color(0xFFE2E0D3);

  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE8A317);
  static const danger = Color(0xFFD64545);
  static const info = Color(0xFF3B6FE0);

  // Dark
  static const darkBg = Color(0xFF121210);
  static const darkCard = Color(0xFF1C1C19);
  static const darkLine = Color(0xFF2E2E29);
  static const darkMuted = Color(0xFF9B9A90);
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 26.0;
  static const pill = 999.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final bg = dark ? AppColors.darkBg : AppColors.cream;
    final card = dark ? AppColors.darkCard : AppColors.card;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final onBg = dark ? const Color(0xFFF4F3EA) : AppColors.ink;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;

    final scheme = ColorScheme(
      brightness: b,
      primary: AppColors.lime,
      onPrimary: AppColors.ink,
      primaryContainer: dark ? const Color(0xFF3A3F0A) : AppColors.limeSoft,
      onPrimaryContainer: dark ? AppColors.limeSoft : AppColors.ink,
      secondary: dark ? const Color(0xFFF4F3EA) : AppColors.ink,
      onSecondary: dark ? AppColors.ink : Colors.white,
      secondaryContainer: dark ? AppColors.darkLine : AppColors.creamDeep,
      onSecondaryContainer: onBg,
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: dark ? const Color(0xFF4A1F1F) : const Color(0xFFFBE3E3),
      onErrorContainer: dark ? const Color(0xFFFFB4B4) : const Color(0xFF7A1F1F),
      surface: bg,
      onSurface: onBg,
      onSurfaceVariant: muted,
      surfaceContainerLowest: card,
      surfaceContainerLow: card,
      surfaceContainer: card,
      surfaceContainerHigh: dark ? AppColors.darkLine : AppColors.creamDeep,
      surfaceContainerHighest: dark ? AppColors.darkLine : AppColors.creamDeep,
      outline: muted,
      outlineVariant: line,
      shadow: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      splashFactory: InkSparkle.splashFactory,
    );

    TextStyle heavy(TextStyle? s, double size, {double ls = -0.5}) =>
        (s ?? const TextStyle()).copyWith(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: ls,
          height: 1.15,
          color: onBg,
        );

    final text = base.textTheme.apply(bodyColor: onBg, displayColor: onBg).copyWith(
          displaySmall: heavy(base.textTheme.displaySmall, 34, ls: -1),
          headlineMedium: heavy(base.textTheme.headlineMedium, 28, ls: -0.8),
          headlineSmall: heavy(base.textTheme.headlineSmall, 24),
          titleLarge: heavy(base.textTheme.titleLarge, 20, ls: -0.3),
          titleMedium: heavy(base.textTheme.titleMedium, 16, ls: -0.2)
              .copyWith(fontWeight: FontWeight.w700),
          titleSmall: heavy(base.textTheme.titleSmall, 14, ls: -0.1)
              .copyWith(fontWeight: FontWeight.w700),
          labelSmall: base.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: muted,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(color: muted),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(color: onBg),
        );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: onBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: heavy(base.textTheme.titleLarge, 20, ls: -0.3),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: line),
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: TextStyle(color: muted, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: muted),
        border: border(line),
        enabledBorder: border(line),
        focusedBorder: border(onBg, 1.6),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
          textStyle: base.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.ink,
          elevation: 0,
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
          textStyle: base.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBg,
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
          side: BorderSide(color: dark ? AppColors.darkMuted : AppColors.ink),
          textStyle: base.textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onBg,
          shape: const StadiumBorder(),
          textStyle: base.textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.ink,
        elevation: 0,
        highlightElevation: 0,
        shape: const StadiumBorder(),
        extendedTextStyle: base.textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: card,
        selectedColor: AppColors.lime,
        checkmarkColor: AppColors.ink,
        side: BorderSide(color: line),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(color: onBg, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
            color: AppColors.ink, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: AppColors.lime,
        height: 68,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
            (base.textTheme.labelMedium ?? const TextStyle()).copyWith(
              fontSize: 12,
              fontWeight:
                  s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? onBg : muted,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? AppColors.ink : muted,
            )),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onBg,
        unselectedLabelColor: muted,
        indicatorColor: onBg,
        dividerColor: line,
        labelStyle: base.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
        unselectedLabelStyle: base.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.ink : muted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.lime : line),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.lime : Colors.transparent),
        checkColor: const WidgetStatePropertyAll(AppColors.ink),
        side: BorderSide(color: dark ? AppColors.darkMuted : AppColors.ink, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(dark ? AppColors.lime : AppColors.ink),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dark ? AppColors.lime : AppColors.ink,
        linearTrackColor: line,
      ),
    );
  }
}
