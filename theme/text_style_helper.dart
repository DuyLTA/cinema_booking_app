import 'package:flutter/material.dart';
import './core/';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Display Styles
  // Large text styles typically used for headers and hero elements

  TextStyle get display48RegularBebasNeue => TextStyle(
    fontSize: 48.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Bebas Neue',
    color: appTheme.orange_100,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20SemiBoldBodoniModa => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Bodoni Moda',
    color: appTheme.colorCCF0DF,
  );

  TextStyle get title20RegularBebasNeue => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'BebasNeue',
    color: appTheme.gray_300,
  );

  TextStyle get title16RegularDMSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'DM Sans',
    color: appTheme.gray_400,
  );

  TextStyle get title16BoldDMSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'DM Sans',
    color: appTheme.orange_100,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14RegularBebasNeue => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Bebas Neue',
    color: appTheme.gray_400,
  );
}
