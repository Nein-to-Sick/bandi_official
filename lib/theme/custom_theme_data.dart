import 'package:flutter/material.dart';

class BandiColor {
  /// Black Color
  static Color foundationColor100(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Black Color
  static Color foundationColor80(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.8);
  }

  /// Black Color
  static Color foundationColor60(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.6);
  }

  /// Black Color
  static Color foundationColor40(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.4);
  }

  /// Black Color
  static Color foundationColor20(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.2);
  }

  /// Black Color
  static Color foundationColor10(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.1);
  }

  /// Neutral Color
  static Color neutralColor100(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Neutral Color
  static Color neutralColor90(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.9);
  }

  /// Neutral Color
  static Color neutralColor80(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.8);
  }

  /// Neutral Color
  static Color neutralColor60(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.6);
  }

  /// Neutral Color
  static Color neutralColor40(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.4);
  }

  /// Neutral Color
  static Color neutralColor20(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.2);
  }

  /// Neutral Color
  static Color neutralColor10(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.1);
  }

  /// Accent Color
  static Color accentColorYellow(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Accent Color
  static Color accentColorRed(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Transparent Color
  static Color transparent(BuildContext context) {
    return Colors.transparent;
  }
}

class BandiFont {
  static TextStyle? displayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge;
  }

  static TextStyle? displayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium;
  }

  static TextStyle? displaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall;
  }

  static TextStyle? headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium;
  }

  static TextStyle? headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall;
  }

  static TextStyle? titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge;
  }

  static TextStyle? titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium;
  }

  static TextStyle? titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall;
  }

  static TextStyle? bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge;
  }

  static TextStyle? bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium;
  }

  static TextStyle? bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall;
  }

  static TextStyle? labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge;
  }

  static TextStyle? labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium;
  }

  static TextStyle? labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall;
  }

  static TextStyle? headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge;
  }

  static medium(BuildContext context) {}
}

class BandiEffects {
  static BorderRadius radius() {
    return BorderRadius.circular(8);
  }

  static double backgroundBlur() {
    return 8;
  }
}

class CustomThemeData {
  static final ThemeData light = ThemeData(
    colorScheme: const ColorScheme.light(
      /// Foundation
      primary: Color(0xff000000),

      /// Neutral
      surface: Color(0xffFFFFFF),

      /// Accent Yellow
      secondary: Color(0xffFFCB46),

      /// Accent Red
      error: Color(0xffC33025),
      onPrimary: Color(0xffFFFFFF),
      onSurface: Color(0xff000000),
      onSecondary: Color(0xff000000),
      onError: Color(0xffFFFFFF),
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
    colorScheme: const ColorScheme.dark(
      primary: Color(0xffffffff),
      surface: Color(0xff000000),
      secondary: Color(0xffFFCB46),
      error: Color(0xffC33025),
      onPrimary: Color(0xff000000),
      onSurface: Color(0xffFFFFFF),
      onSecondary: Color(0xff000000),
      onError: Color(0xffFFFFFF),
    ),
    disabledColor: const Color(0xff1C1C1C), // Border
    dividerColor: const Color(0xff444444), // Button -inactive
    focusColor: const Color(0xff6E6E6E),
    highlightColor: const Color(0xffA2A2A2), // Label
    hintColor: const Color(0xffC2C2C2), // Text
    hoverColor: const Color(0xffE2E2E2), // Header
    textTheme: textTheme,
  );

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

  static TextTheme textTheme = const TextTheme(
    /**Headline1 */
    displayLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w600, // SemiBold
    ),
    /**Headline2 */
    displayMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600, // SemiBold
    ),
    /**Headline3 */
    displaySmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600, // SemiBold
    ),
    /**Headline4 */
    headlineMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 16,
      height: 26 / 16,
      fontWeight: FontWeight.w600, // SemiBold
    ),
    /**Body1 */
    titleMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400, // Regular
    ),
    /**Body2 */
    titleSmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 14,
      height: 26 / 14,
      fontWeight: FontWeight.w400, // Regular
    ),
    /**Body3 */
    headlineSmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400, // Regular
    ),
    /**Normal */
    bodyLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500, // Medium
    ),
    /**Medium */
    bodyMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w500, // Medium
    ),
    /**Small */
    bodySmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 14,
      height: 16 / 14,
      fontWeight: FontWeight.w500, // Medium
    ),
    /**Small2 */
    labelLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 11,
      height: 19 / 11,
      fontWeight: FontWeight.w600, // SemiBold
    ),
    /**Text1 */
    labelMedium: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400, // Regular
    ),
    /**Text2 */
    labelSmall: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 11,
      height: 24 / 11,
      fontWeight: FontWeight.w400, // Regular
    ),
    /**Mobile & Field */
    headlineLarge: TextStyle(
      fontFamily: "IBMPlexSansKR",
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600, // SemiBold
    ),
  );
}
