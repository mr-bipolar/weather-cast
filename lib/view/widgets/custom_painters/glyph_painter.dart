import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/weather_scene.dart';

class GlyphPainter extends CustomPainter {
  GlyphPainter(this.scene);

  final WeatherScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (scene.kind) {
      case WeatherSceneTypes.clear:
        if (scene.isNight) {
          final outer = Path()
            ..addOval(
              Rect.fromCircle(
                center: Offset(w * 0.5, h * 0.5),
                radius: w * 0.26,
              ),
            );
          final cut = Path()
            ..addOval(
              Rect.fromCircle(
                center: Offset(w * 0.61, h * 0.43),
                radius: w * 0.24,
              ),
            );
          canvas.drawPath(
            Path.combine(PathOperation.difference, outer, cut),
            Paint()..color = ColorPalette.moon,
          );
        } else {
          canvas.drawCircle(
            Offset(w * 0.5, h * 0.5),
            w * 0.26,
            Paint()..color = ColorPalette.sunGold,
          );
        }
        break;
      case WeatherSceneTypes.snow:
        final flake = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 3; i++) {
          final a = i * math.pi / 3;
          canvas.drawLine(
            Offset(
              w * 0.5 - math.cos(a) * w * 0.28,
              h * 0.5 - math.sin(a) * h * 0.28,
            ),
            Offset(
              w * 0.5 + math.cos(a) * w * 0.28,
              h * 0.5 + math.sin(a) * h * 0.28,
            ),
            flake,
          );
        }
        break;
      case WeatherSceneTypes.thunderstorm:
      case WeatherSceneTypes.storm:
        _cloud(canvas, w, h, const Color(0xFFD9D3EE));
        final bolt = Path()
          ..moveTo(w * 0.54, h * 0.46)
          ..lineTo(w * 0.44, h * 0.68)
          ..lineTo(w * 0.53, h * 0.67)
          ..lineTo(w * 0.47, h * 0.86)
          ..lineTo(w * 0.65, h * 0.60)
          ..lineTo(w * 0.55, h * 0.61)
          ..close();
        canvas.drawPath(bolt, Paint()..color = const Color(0xFFFFE27A));
        break;
      case WeatherSceneTypes.rain:
        _cloud(canvas, w, h, const Color(0xFFE6EEF4));
        final drop = Paint()
          ..color = const Color(0xFF9FC6DD)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 3; i++) {
          final x = w * (0.34 + i * 0.16);
          canvas.drawLine(Offset(x, h * 0.62), Offset(x - 1.5, h * 0.82), drop);
        }
        break;
      case WeatherSceneTypes.fog:
        final band = Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 3; i++) {
          final y = h * (0.34 + i * 0.16);
          canvas.drawLine(Offset(w * 0.20, y), Offset(w * 0.80, y), band);
        }
        break;
      case WeatherSceneTypes.haze:
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.48),
          w * 0.25,
          Paint()..color = const Color(0xFFF2C98F),
        );
        canvas.drawLine(
          Offset(w * 0.20, h * 0.76),
          Offset(w * 0.80, h * 0.76),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.55)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
        break;
      case WeatherSceneTypes.clouds:
        _cloud(canvas, w, h, Colors.white);
        break;
    }
  }

  void _cloud(Canvas canvas, double w, double h, Color color) {
    final paint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.56),
        width: w * 0.68,
        height: h * 0.34,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.40, h * 0.44),
        width: w * 0.34,
        height: h * 0.34,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.60, h * 0.40),
        width: w * 0.32,
        height: h * 0.32,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant GlyphPainter oldDelegate) {
    return oldDelegate.scene.kind != scene.kind ||
        oldDelegate.scene.isNight != scene.isNight;
  }
}
