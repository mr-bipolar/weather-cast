import 'package:flutter/material.dart';
import 'package:weather/theme/color_palette.dart';

class CustomTextStyle {
  CustomTextStyle._();

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
}
