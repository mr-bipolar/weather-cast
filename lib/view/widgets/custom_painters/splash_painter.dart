import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/color_palette.dart';

class SplashPainter extends CustomPainter {
  const SplashPainter();

  static final List<Offset> _stars = _buildStars();

  static List<Offset> _buildStars() {
    final rng = math.Random(7);
    return List.generate(34, (_) {
      return Offset(rng.nextDouble(), rng.nextDouble() * 0.42);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintHalo(canvas, size);
    _paintStars(canvas, size);
    _paintHills(canvas, size);
  }

  //* Warm light sitting low behind the mark, plus a soft horizon wash.
  void _paintHalo(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.5, size.height * 0.44);
    final radius = size.width * 0.62;
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x29F6C86A), Color(0x14F2A97E), Color(0x00F2A97E)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );

    final horizon = Offset(size.width * 0.5, size.height * 0.72);
    final horizonRadius = size.width * 0.55;
    canvas.drawCircle(
      horizon,
      horizonRadius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x14F6C86A), Color(0x00F6C86A)],
        ).createShader(Rect.fromCircle(center: horizon, radius: horizonRadius)),
    );
  }

  void _paintStars(Canvas canvas, Size size) {
    for (final star in _stars) {
      final alpha = 0.28 + (star.dx * 0.30);
      final radius = 0.9 + (star.dy * 2.0);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        radius,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _paintHills(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.77,
        size.width * 0.50,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.87,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      back,
      Paint()
        ..shader =
            LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [
                ColorPalette.nightBottom.fade(0.55),
                ColorPalette.nightBottom.fade(0.90),
              ],
            ).createShader(
              Rect.fromLTWH(
                0,
                size.height * 0.77,
                size.width,
                size.height * 0.23,
              ),
            ),
    );

    final rim = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.77,
        size.width * 0.50,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.87,
        size.width,
        size.height * 0.80,
      );
    canvas.drawPath(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ColorPalette.turquoise.fade(0.10),
    );

    final front = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.83,
        size.width * 0.58,
        size.height * 0.89,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.93,
        size.width,
        size.height * 0.87,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      front,
      Paint()
        ..shader =
            LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [
                ColorPalette.nightBottom.fade(0.82),
                ColorPalette.nightBottom.fade(0.98),
              ],
            ).createShader(
              Rect.fromLTWH(
                0,
                size.height * 0.84,
                size.width,
                size.height * 0.16,
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(SplashPainter oldDelegate) => false;
}
