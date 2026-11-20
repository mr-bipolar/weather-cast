import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/weather_scene.dart';

class StaticScenePainter extends CustomPainter {
  final WeatherScene scene;
  final List<Offset> _stars;

  StaticScenePainter({required this.scene}) : _stars = _buildStars(scene);

  static List<Offset> _buildStars(WeatherScene scene) {
    if (!scene.isNight) return const [];
    final rng = math.Random(11);
    return List.generate(38, (_) {
      return Offset(rng.nextDouble(), rng.nextDouble() * 0.55);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintSkyLight(canvas, size);
    _paintStars(canvas, size);
    _paintHills(canvas, size);
  }

  // Sun / moon glow behind the clouds
  void _paintSkyLight(Canvas canvas, Size size) {
    if (scene.kind == WeatherSceneTypes.clear && !scene.isNight) return;

    final center = Offset(size.width * 0.68, size.height * 0.22);
    final radius = size.width * 0.22;
    final glow = scene.glowColor;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glow.withValues(alpha: scene.isNight ? 0.36 : 0.62),
            glow.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    if (scene.isNight) {
      // Crescent moon disc
      final moonRadius = size.width * 0.085;
      canvas.drawCircle(
        center,
        moonRadius,
        Paint()..color = ColorPalette.moon.withValues(alpha: 0.92),
      );
      canvas.drawCircle(
        center.translate(moonRadius * 0.42, -moonRadius * 0.26),
        moonRadius * 0.92,
        Paint()..color = scene.gradient.first.fade(0.96),
      );
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.fade(0.55);
    for (final star in _stars) {
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        1.2,
        paint,
      );
    }
  }

  // Soft foreground land mass
  void _paintHills(Canvas canvas, Size size) {
    final hill = Path()
      ..moveTo(0, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.72,
        size.width * 0.48,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.86,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      hill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scene.shadowColor.withValues(alpha: 0.22),
            scene.shadowColor.withValues(alpha: 0.52),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant StaticScenePainter oldDelegate) {
    return oldDelegate.scene.kind != scene.kind ||
        oldDelegate.scene.isNight != scene.isNight;
  }
}
