import 'package:flutter/material.dart';

// Raw Color 값 정의
class BandiPalette {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Yellow Hex Code
  static const Color yellow = Color(0xFFFFDB58);

  // Red Hex Code
  static const Color red = Color(0xFFFF5C46);
}

class BandiColor {
  /// --------------------------------------------------------------------------
  /// Foundation Color (Light: Black / Dark: White)
  /// Theme.of(context).colorScheme.onSurface를 참조
  /// --------------------------------------------------------------------------

  static Color foundationColor100(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color foundationColor90(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.9);
  }

  static Color foundationColor80(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.8);
  }

  static Color foundationColor70(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  static Color foundationColor60(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  }

  static Color foundationColor50(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
  }

  static Color foundationColor40(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
  }

  static Color foundationColor30(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
  }

  static Color foundationColor20(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.2);
  }

  static Color foundationColor10(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.1);
  }

  static Color foundationColor04(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.04);
  }

  /// --------------------------------------------------------------------------
  /// Neutral Color (Light: White / Dark: Black)
  /// Theme.of(context).colorScheme.surface를 참조
  /// --------------------------------------------------------------------------

  static Color neutralColor100(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color neutralColor90(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.9);
  }

  static Color neutralColor80(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.8);
  }

  static Color neutralColor70(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.7);
  }

  static Color neutralColor60(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.6);
  }

  static Color neutralColor50(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.5);
  }

  static Color neutralColor40(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.4);
  }

  static Color neutralColor30(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.3);
  }

  static Color neutralColor20(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.2);
  }

  static Color neutralColor10(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.1);
  }

  static Color neutralColor04(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.04);
  }

  /// --------------------------------------------------------------------------
  /// Accent & Semantic Colors
  /// --------------------------------------------------------------------------

  /// Primary (Yellow)
  static Color accentColorYellow(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Semantic (Red)
  static Color accentColorRed(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Transparent
  static Color transparent(BuildContext context) {
    return Colors.transparent;
  }
}

class BandiFont {
  // Helper methods to easily access styles from context
  static TextStyle? displayLarge(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge;
  static TextStyle? headlineLarge(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;
  static TextStyle? headlineMedium(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;
  static TextStyle? titleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;
  static TextStyle? titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;
  static TextStyle? bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge;
  static TextStyle? bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
  static TextStyle? bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;
  static TextStyle? labelLarge(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;
  static TextStyle? labelMedium(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium;
  static TextStyle? labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;
}

class BandiEffects {
  // raw value
  static const double radiusValueSmall = 24.0;
  static const double radiusValueLarge = 100.0;

  static final BorderRadius radiusSmall =
      BorderRadius.circular(radiusValueSmall);
  static final BorderRadius radiusLarge =
      BorderRadius.circular(radiusValueLarge);

  static const double blurSmall = 4.0;
  static const double blurLarge = 16.0;
}

class CustomThemeData {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      /// [Primary] Image: Yellow
      primary: BandiPalette.yellow,
      onPrimary: BandiPalette.black,

      /// [Content] Image: White (Background) / Black (Text)
      surface: BandiPalette.white,
      onSurface: BandiPalette.black,

      /// [Semantic] Image: Red
      error: BandiPalette.red,
      onError: BandiPalette.black,

      // Accent Yellow
      secondary: BandiPalette.yellow,
      onSecondary: BandiPalette.black,
    ),
    disabledColor: const Color(0xffF7F7F7), // Border
    dividerColor: const Color(0xffD5D5D5), // Button -inactive
    focusColor: const Color(0xffB4B4B4),
    highlightColor: const Color(0xff6E6E6E), // Label
    hintColor: const Color(0xff4E4E4E), // Text
    hoverColor: const Color(0xff2E2E2E), // Header
    textTheme: textTheme,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      /// [Primary] Dark Mode에서도 브랜드 컬러 유지
      primary: BandiPalette.yellow,
      onPrimary: BandiPalette.black,

      /// [Content] Image: Black (Background) / White (Text)
      surface: BandiPalette.black,
      onSurface: BandiPalette.white,

      /// [Semantic]
      error: BandiPalette.red,
      onError: BandiPalette.black,

      // Accent Yellow
      secondary: BandiPalette.yellow,
      onSecondary: BandiPalette.black,
    ),
    disabledColor: const Color(0xff1C1C1C), // Border
    dividerColor: const Color(0xff444444), // Button -inactive
    focusColor: const Color(0xff6E6E6E),
    highlightColor: const Color(0xffA2A2A2), // Label
    hintColor: const Color(0xffC2C2C2), // Text
    hoverColor: const Color(0xffE2E2E2), // Header
    textTheme: textTheme,
  );

  // ---------------------------------------------------------------------------
  // TEXT THEME DEFINITION
  // ---------------------------------------------------------------------------

  /*
    FontWeight.w100: Thin
    FontWeight.w200: ExtraLight
    FontWeight.w300: Light
    FontWeight.w400: Regular
    FontWeight.w500: Medium
    FontWeight.w600: SemiBold
    FontWeight.w700: Bold
    FontWeight.w800: ExtraBold
    FontWeight.w900: Black
  */

  static const TextTheme textTheme = TextTheme(
    /// [Display]
    /// Image: Display (50px / 120% / 0.00% / SemiBold)
    displayLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 50,
      height: 1.2, // 120%
      letterSpacing: 0.0, // 0%
      fontWeight: FontWeight.w600,
    ),

    /// [Headline 1]
    /// Image: Headline 1 (20px / 130% / -1.00% / SemiBold)
    headlineLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 20,
      height: 1.3, // 130%
      letterSpacing: -0.2, // 20 * -0.01
      fontWeight: FontWeight.w600,
    ),

    /// [Headline 2]
    /// Image: Headline 2 (18px / 130% / -1.00% / SemiBold)
    headlineMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 18,
      height: 1.3, // 130%
      letterSpacing: -0.18, // 18 * -0.01
      fontWeight: FontWeight.w600,
    ),

    /// [Subtitle 1]
    /// Image: Subtitle 1 (16px / 140% / -1.00% / Medium)
    titleMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 16,
      height: 1.4, // 140%
      letterSpacing: -0.16, // 16 * -0.01
      fontWeight: FontWeight.w500,
    ),

    /// [Subtitle 2]
    /// Image: Subtitle 2 (14px / 140% / -1.00% / Medium)
    titleSmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 14,
      height: 1.4, // 140%
      letterSpacing: -0.14, // 14 * -0.01
      fontWeight: FontWeight.w500,
    ),

    /// [Body 1] & [Placeholder]
    /// Image: Body 1 (14px / 180% / -1.00% / Regular)
    /// Image: Placeholder (Same specs)
    bodyLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 14,
      height: 1.8, // 180%
      letterSpacing: -0.14, // 14 * -0.01
      fontWeight: FontWeight.w400,
    ),

    /// [Body 2]
    /// Image: Body 2 (12px / 160% / -1.00% / Regular)
    bodyMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 12,
      height: 1.6, // 160%
      letterSpacing: -0.12, // 12 * -0.01
      fontWeight: FontWeight.w400,
    ),

    /// [Body 3]
    /// Image: Body 3 (12px / 130% / -1.00% / SemiBold)
    bodySmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 12,
      height: 1.3, // 130%
      letterSpacing: -0.12, // 12 * -0.01
      fontWeight: FontWeight.w600,
    ),

    /// [Button 1]
    /// Image: Button 1 (16px / 120% / -1.00% / Medium)
    labelLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 16,
      height: 1.2, // 120%
      letterSpacing: -0.16, // 16 * -0.01
      fontWeight: FontWeight.w500,
    ),

    /// [Button 2]
    /// Image: Button 2 (12px / 130% / -1.00% / Medium)
    labelMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 12,
      height: 1.3, // 130%
      letterSpacing: -0.12, // 12 * -0.01
      fontWeight: FontWeight.w500,
    ),

    /// [Caption/Subtext]
    /// Image: Caption 2 (12px / 140% / -1.00% / Regular)
    /// Caption 1(14px/140%)은 titleSmall과 유사하고, Caption 2를 labelSmall에 배정
    labelSmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 12,
      height: 1.4, // 140%
      letterSpacing: -0.12, // 12 * -0.01
      fontWeight: FontWeight.w400,
    ),
  );
}
