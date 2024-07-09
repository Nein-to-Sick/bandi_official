import 'package:flutter/material.dart';

class BandiColor {
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color accentColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color errorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color gray001Color(BuildContext context) {
    return Theme.of(context).disabledColor;
  }

  static Color gray002Color(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  static Color gray003Color(BuildContext context) {
    return Theme.of(context).focusColor;
  }

  static Color gray004Color(BuildContext context) {
    return Theme.of(context).highlightColor;
  }

  static Color gray005Color(BuildContext context) {
    return Theme.of(context).hintColor;
  }

  static Color gray006Color(BuildContext context) {
    return Theme.of(context).hoverColor;
  }

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

//  TODO: 추후 색상 수정 필요
class CustomThemeData {
  static final ThemeData light = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xff000000),
      surface: Color(0xffFFFFFF),
      secondary: Color(0xffFFCB46),
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

  //  TODO: 추후 폰트 수정 필요
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: "IBMPlexSansSemiBold",
      fontSize: 28,
      height: 36 / 28,
    ),
    displayMedium: TextStyle(
      fontFamily: "IBMPlexSansSemiBold",
      fontSize: 20,
      height: 28 / 20,
    ),
    displaySmall: TextStyle(
      fontFamily: "IBMPlexSansSemiBold",
      fontSize: 18,
      height: 24 / 18,
    ),
    headlineMedium: TextStyle(
      fontFamily: "IBMPlexSansSemiBold",
      fontSize: 16,
      height: 20 / 16,
    ),
    titleMedium: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 16,
      height: 24 / 16,
    ),
    titleSmall: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 14,
      height: 20 / 14,
    ),
    headlineSmall: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 12,
      height: 16 / 12,
    ),
    bodyLarge: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 18,
      height: 24 / 18,
    ),
    bodyMedium: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 16,
      height: 20 / 16,
    ),
    bodySmall: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 14,
      height: 16 / 14,
    ),
    labelLarge: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 11,
      height: 22 / 11,
    ),
    labelMedium: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 16,
      height: 24 / 16,
    ),
    labelSmall: TextStyle(
      fontFamily: "IBMPlexSansRegular",
      fontSize: 12,
      height: 16 / 12,
    ),
    headlineLarge: TextStyle(
      fontFamily: "IBMPlexSansSemiBold",
      fontSize: 16,
      height: 24 / 16,
    ),
  );
}
