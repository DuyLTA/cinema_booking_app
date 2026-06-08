import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get orange_100 => Color(0xFFFFDF9E);
  Color get gray_900 => Color(0xFF5C0612);
  Color get gray_300 => Color(0xFFF0DFDB);
  Color get gray_400 => Color(0xFFDCC0BF);
  Color get gray_500 => Color(0xFFA48B8A);
  Color get black_900 => Color(0xFF140C0B);
  Color get deep_orange_100_33 => Color(0x33FFB3B2);
  Color get blue_gray_900_66 => Color(0x663C3330);
  Color get gray_900_cc => Color(0xCC261E1B);
  Color get black_900_3f => Color(0x3F000000);
  Color get gray_900_01 => Color(0xFF191210);
  Color get screenBackground => Color(0xFF1A1615);
  Color get bookRedDark => Color(0xFF5C0612);
  Color get bookRedFill => Color(0xFF5D0A11);
  Color get bookRedBorder => Color(0xFF9B2430);
  Color get bookRedDarker => Color(0xFF3A0409);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get redCustom => Colors.red;
  Color get greyCustom => Colors.grey;
  Color get color7FFFDF => Color(0x7FFFDF9E);
  Color get colorCCF0DF => Color(0xCCF0DFDB);
  Color get color19A48B => Color(0x19A48B8A);
  Color get color005C06 => Color(0x005C0612);
  Color get color33A48B => Color(0x33A48B8A);
  Color get color99A48B => Color(0x99A48B8A);
  Color get color33FFDF => Color(0x33FFDF9E);
  Color get color66A48B => Color(0x66A48B8A);
  Color get color0C665C => Color(0x0C665C06);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;

  Color get deep_orange_100 => Color(0xFFFFB3B2);

  Color get gray_900_02 => Color(0xFF261B19);
  Color get gray_900_03 => Color(0xFF312826);

  Color get black_900_7f => Color(0x7F000000);
  Color get amber_A400 => Color(0xFFFABD00);
  Color get gray_900_04 => Color(0xFF261E1B);
  Color get gray_800 => Color(0xFF564241);
  Color get gray_900_05 => Color(0xFF2A1F1D);
  Color get gray_900_06 => Color(0xFF1C1412);
  Color get lime_900 => Color(0xFF6A4E00);

  Color get color991912 => Color(0x99191210);
  Color get color001912 => Color(0x00191210);
  Color get color33FFB3 => Color(0x33FFB3B2);
  Color get color33FABD => Color(0x33FABD00);
  Color get color995C06 => Color(0x995C0612);
  Color get color19FABD => Color(0x19FABD00);
  Color get color4CFFDF => Color(0x4CFFDF9E);
  Color get color195C06 => Color(0x195C0612);
  Color get color4CFFB3 => Color(0x4CFFB3B2);
  Color get color19FFB3 => Color(0x19FFB3B2);
  Color get colorCC261E => Color(0xCC261E1B);
  Color get colorFF8888 => Color(0xFF888888);
  Color get color19FFDF => Color(0x19FFDF9E);
  Color get colorF21912 => Color(0xF2191210);
  Color get color7FA48B => Color(0x7FA48B8A);
  Color get color335C06 => Color(0x335C0612);
  Color get colorCC5C06 => Color(0xCC5C0612);
  Color get color4C4CFF => Color(0x4C4CFFB3);
  Color get color7F5C06 => Color(0x7F5C0612);
  Color get colorE51912 => Color(0xE5191210);
  Color get color4C5C06 => Color(0x4C5C0612);
  Color get colorB24CFF => Color(0xB24CFFB3);
  Color get color66FFDF => Color(0x66FFDF9E);

  // Color Shades - Each shade has its own dedicated constant
}
