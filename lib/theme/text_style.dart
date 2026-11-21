import 'package:flutter/material.dart';
import 'package:weather/theme/color_palette.dart';

class CustomTextStyle {
  const CustomTextStyle._();

  static const List<Shadow> _textShadow = [
    Shadow(color: Color(0x73000000), blurRadius: 8, offset: Offset(0, 1)),
  ];

  // Location text style
  static const TextStyle location = TextStyle(
    color: ColorPalette.ink,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    shadows: _textShadow,
  );

  static const TextStyle caption = TextStyle(
    color: ColorPalette.muted,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    shadows: _textShadow,
  );

  static const TextStyle temperature = TextStyle(
    color: ColorPalette.ink,
    fontSize: 68,
    fontWeight: FontWeight.w200,
    letterSpacing: -3,
    height: 0.98,
    fontFeatures: [FontFeature.tabularFigures()],
    shadows: _textShadow,
  );

  static const TextStyle condition = TextStyle(
    color: ColorPalette.ink,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.4,
    shadows: _textShadow,
  );

  static const TextStyle highlight = TextStyle(
    color: ColorPalette.faint,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    shadows: _textShadow,
  );

  static const TextStyle railTime = TextStyle(
    color: ColorPalette.muted,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    shadows: _textShadow,
  );

  static const TextStyle railTemp = TextStyle(
    color: ColorPalette.ink,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    shadows: _textShadow,
  );

  static const TextStyle metricLabel = TextStyle(
    color: Color(0xFFDDE1EB),
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.7,
    shadows: _textShadow,
  );

  static const TextStyle metricValue = TextStyle(
    color: ColorPalette.ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    shadows: _textShadow,
  );
}
