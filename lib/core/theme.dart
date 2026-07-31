import 'package:flutter/material.dart';

/// Easter egg: tapping the app icon in [TabHeading] cycles through these,
/// in order, wrapping back to [green]. [system] is skipped when the device
/// has no Material You palette to offer (anything pre-Android-12, or a
/// non-Android platform) - see `data/providers.dart`'s
/// `systemCorePaletteProvider`.
enum ThemeSeedOption { green, blue, magenta, monochrome, system }

/// Display name shown in the "Theme changed to ..." toast - see
/// [TabHeading]'s tap handler.
extension ThemeSeedOptionLabel on ThemeSeedOption {
  String get label => switch (this) {
        ThemeSeedOption.green => 'green',
        ThemeSeedOption.blue => 'blue',
        ThemeSeedOption.magenta => 'magenta',
        ThemeSeedOption.monochrome => 'monochrome',
        ThemeSeedOption.system => 'system',
      };
}

/// intrval's app theme: Material 3, kept deliberately plain in structure but
/// given a bit of polish through shape, weight and spacing rather than
/// decoration.
///
/// The palette is seeded with the moss green that dominates the app icon's
/// artwork, so the UI and the launcher icon read as the same product by
/// default - [ThemeSeedOption] offers a few alternates as an easter egg.
class AppTheme {
  /// Sampled from the icon's dominant green (`#49601C`-`#74893E` range),
  /// nudged slightly brighter so Material 3 derives a usable accent from it.
  static const Color seed = Color(0xFF5E7C24);

  static const Color seedBlue = Color(0xFF245E7C);
  static const Color seedMagenta = Color(0xFF7C245E);

  static ThemeData light(ThemeSeedOption option, {ColorScheme? systemScheme}) =>
      _build(Brightness.light, option, systemScheme: systemScheme);

  static ThemeData dark(ThemeSeedOption option, {ColorScheme? systemScheme}) =>
      _build(Brightness.dark, option, systemScheme: systemScheme);

  static ThemeData _build(
    Brightness brightness,
    ThemeSeedOption option, {
    ColorScheme? systemScheme,
  }) {
    final colors = _colorScheme(brightness, option, systemScheme);
    final base = ThemeData(useMaterial3: true, colorScheme: colors);

    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        titleTextStyle: base.textTheme.headlineLarge?.copyWith(fontSize: 32),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainer,
        surfaceTintColor: colors.surfaceContainer,
        indicatorColor: colors.secondaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      // A slim track with a compact thumb reads as a progress indicator you
      // can grab, rather than Material's default chunky form control.
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.surfaceContainerHighest,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.12),
        thumbSize: const WidgetStatePropertyAll(Size(4, 20)),
        trackGap: 4,
        padding: EdgeInsets.zero,
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // Material 3's default is EdgeInsetsDirectional.only(start: 16, end:
        // 24) - 8dp heavier on the trailing side by spec. That's what made
        // list rows look right-heavy; force it symmetric instead.
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: base.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: base.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
      ),
    );
  }

  static ColorScheme _colorScheme(
    Brightness brightness,
    ThemeSeedOption option,
    ColorScheme? systemScheme,
  ) {
    switch (option) {
      case ThemeSeedOption.system:
        // Falls back to the default green if the caller didn't resolve a
        // system palette (e.g. it's still loading, or unavailable on this
        // device) - the tap handler is expected to skip this option
        // entirely in that case, but this keeps _build safe regardless.
        //
        // [systemScheme] itself is never used directly: it comes from
        // dynamic_color's `CorePalette.toColorScheme()`, which is built on
        // the legacy (pre-M3-surface-container-roles) `Scheme` API and never
        // populates `surfaceContainer`/`surfaceContainerHigh`/etc - so the
        // nav bar, search field fill, and mini player would all render with
        // the same fallback color instead of the tiered elevation the other
        // options get. Re-seeding from just its primary color runs that
        // color back through the same modern algorithm as every other
        // option, which does compute those roles correctly.
        if (systemScheme == null) {
          return ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
        }
        return ColorScheme.fromSeed(
          seedColor: systemScheme.primary,
          brightness: brightness,
        );
      case ThemeSeedOption.monochrome:
        // The "monochrome" dynamic scheme variant forces chroma to 0 across
        // every tonal palette, so the actual seed hue is irrelevant here -
        // this is what makes a genuine black/white/greyscale Material 3
        // theme possible at all; a plain grey seed color under the default
        // "tonalSpot" variant would still pick up a faint tint.
        return ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        );
      case ThemeSeedOption.blue:
        return ColorScheme.fromSeed(
          seedColor: seedBlue,
          brightness: brightness,
        );
      case ThemeSeedOption.magenta:
        return ColorScheme.fromSeed(
          seedColor: seedMagenta,
          brightness: brightness,
        );
      case ThemeSeedOption.green:
        return ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    }
  }
}
