import 'package:flutter/material.dart';

extension ColorsExtension on Color {
  Color fade(double value) => withValues(alpha: value);
  Color redValue(double value) => withValues(red: value);
  Color greenValue(double value) => withValues(green: value);
  Color blueValue(double value) => withValues(blue: value);
}
