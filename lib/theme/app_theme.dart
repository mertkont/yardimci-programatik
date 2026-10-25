import 'package:flutter/material.dart';

/// Semantic colors that aren't covered by [ColorScheme], exposed as a theme
/// extension so widgets read them via `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color ink; // primary text
  final Color muted; // secondary text
  final Color line; // hairline borders
  final Color track; // chip / progress track background
  final Color accent; // secondary highlight (sky)
  final Color success;
  final Color warn;
  final Color danger;
  final Color neutral;

  const AppPalette({
    required this.ink,
    required this.muted,
    required this.line,
    required this.track,
    required this.accent,
    required this.success,
    required this.warn,
    required this.danger,
    required this.neutral,
  });

  @override
  AppPalette copyWith({
    Color? ink,
    Color? muted,
    Color? line,
    Color? track,
    Color? accent,
    Color? success,
    Color? warn,
    Color? danger,
    Color? neutral,
  }) =>
      AppPalette(
        ink: ink ?? this.ink,
        muted: muted ?? this.muted,
        line: line ?? this.line,
        track: track ?? this.track,
        accent: accent ?? this.accent,
        success: success ?? this.success,
        warn: warn ?? this.warn,
        danger: danger ?? this.danger,
        neutral: neutral ?? this.neutral,
      );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      track: Color.lerp(track, other.track, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

class AppTheme {
  static const _bgLight = Color(0xFFF4F6FB);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF4F46E5);

  static const _bgDark = Color(0xFF0D0F17);
  static const _surfaceDark = Color(0xFF161A27);
  static const _primaryDark = Color(0xFF8B83FF);

  static const _paletteLight = AppPalette(
    ink: Color(0xFF14172A),
    muted: Color(0xFF6A7186),
    line: Color(0xFFE6E9F2),
    track: Color(0xFFEEF1F8),
    accent: Color(0xFF0EA5E9),
    success: Color(0xFF15A34A),
    warn: Color(0xFFE08600),
    danger: Color(0xFFDC2626),
    neutral: Color(0xFF64748B),
  );

  static const _paletteDark = AppPalette(
    ink: Color(0xFFECEEF6),
    muted: Color(0xFF98A0B5),
    line: Color(0xFF272C3C),
    track: Color(0xFF1F2433),
    accent: Color(0xFF38BDF8),
    success: Color(0xFF34D399),
    warn: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    neutral: Color(0xFF94A3B8),
  );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: _bgLight,
        surface: _surfaceLight,
        primary: _primary,
        primaryTint: const Color(0xFFEBEAFE),
        palette: _paletteLight,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: _bgDark,
        surface: _surfaceDark,
        primary: _primaryDark,
        primaryTint: const Color(0xFF211F3D),
        palette: _paletteDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color primary,
    required Color primaryTint,
    required AppPalette palette,
  }) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      surface: surface,
      primaryContainer: primaryTint,
      onPrimaryContainer: primary,
      surfaceContainerHighest: palette.track,
    );

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final display = base.textTheme.apply(fontFamily: 'SpaceGrotesk');

    final text = base.textTheme
        .apply(
          fontFamily: 'Inter',
          bodyColor: palette.ink,
          displayColor: palette.ink,
        )
        .copyWith(
          displayLarge: display.displayLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: palette.ink),
          displayMedium: display.displayMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: palette.ink),
          displaySmall: display.displaySmall
              ?.copyWith(fontWeight: FontWeight.w700, color: palette.ink),
          headlineMedium: display.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: palette.ink),
          headlineSmall: display.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: palette.ink),
          titleLarge: display.titleLarge?.copyWith(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: palette.ink),
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: text,
      extensions: [palette],
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        foregroundColor: palette.ink,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: palette.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryTint,
        height: 68,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? primary
                : palette.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? primary
                : palette.muted,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? palette.track : palette.track,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: palette.muted),
        labelStyle: TextStyle(color: palette.muted),
        floatingLabelStyle: TextStyle(color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.track,
        selectedColor: primaryTint,
        side: BorderSide(color: palette.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: palette.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        extendedTextStyle: const TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.ink,
        contentTextStyle:
            const TextStyle(fontFamily: 'Inter', color: Colors.white),
      ),
    );
  }
}
