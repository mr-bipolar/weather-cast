import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:weather/core/animations/ambient_motion.dart';
import 'package:weather/core/enums/mood_types.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/weather_scene.dart';

class CharacterPainter extends CustomPainter {
  CharacterPainter(this.scene, this.motion) : super(repaint: motion);

  final WeatherScene scene;
  final Animation<double>? motion;

  double get _t => motion?.value ?? 0.0;

  /// open eyes.
  bool get _blinking => Ambient.wrap(_t * 6 + 0.33, 0, 1) < 0.03;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final t = _t;

    // Idle float + breath, pivoting on the character centre.
    final bob = math.sin(t * math.pi * 8 + scene.kind.index * 0.3) * s * 0.014;
    final breath = 1 + math.sin(t * math.pi * 8 + 1.1) * 0.006;

    canvas.save();
    canvas.translate(c.dx, c.dy + bob);
    canvas.scale(breath, breath);
    canvas.translate(-c.dx, -c.dy);

    switch (scene.kind) {
      case WeatherSceneTypes.clear:
      case WeatherSceneTypes.haze:
        _paintSun(
          canvas,
          c,
          s,
          sleepy: scene.kind == WeatherSceneTypes.haze,
          blink: _blinking,
          t: t,
        );
        break;
      case WeatherSceneTypes.clouds:
        _paintCloud(canvas, c, s, mood: Mood.happy, blink: _blinking);
        break;
      case WeatherSceneTypes.rain:
        _paintCloud(
          canvas,
          c,
          s,
          mood: Mood.gloomy,
          rain: true,
          blink: _blinking,
        );
        break;
      case WeatherSceneTypes.thunderstorm:
      case WeatherSceneTypes.storm:
        _paintCloud(
          canvas,
          c,
          s,
          mood: Mood.stormy,
          bolt: true,
          blink: _blinking,
        );
        break;
      case WeatherSceneTypes.snow:
        _paintSnowman(canvas, c, s, blink: _blinking);
        break;
      case WeatherSceneTypes.fog:
        _paintFogWisp(canvas, c, s, blink: _blinking);
        break;
    }

    canvas.restore();
  }

  // sun
  void _paintSun(
    Canvas canvas,
    Offset c,
    double s, {
    bool sleepy = false,
    required bool blink,
    required double t,
  }) {
    final radius = s * 0.27;

    // Gentle glow pulse behind the body
    if (!sleepy) {
      final halo = radius * (1.55 + 0.05 * math.sin(t * math.pi * 4));
      final alpha = 0.20 + 0.06 * math.sin(t * math.pi * 4);
      canvas.drawCircle(
        c,
        halo,
        Paint()
          ..shader = RadialGradient(
            colors: [
              ColorPalette.sunGold.fade(alpha),
              ColorPalette.sunGold.fade(0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: halo)),
      );
    }

    // Rays
    final rayPaint = Paint()
      ..color = ColorPalette.sunGold.fade(0.55)
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final inner = radius * 1.30;
      final shimmer = 1 + 0.05 * math.sin(t * math.pi * 10 + i * 0.7);
      final outer = radius * (i.isEven ? 1.72 : 1.52) * shimmer;
      canvas.drawLine(
        c + Offset(math.cos(a) * inner, math.sin(a) * inner),
        c + Offset(math.cos(a) * outer, math.sin(a) * outer),
        rayPaint,
      );
    }

    // Body
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.30, -0.36),
          colors: [Color(0xFFFFF7D6), Color(0xFFFFD873), Color(0xFFF0A63F)],
          stops: [0.0, 0.58, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.012
        ..color = const Color(0xFFE8A23F).fade(0.55),
    );

    // Face
    final eyeY = c.dy - radius * 0.10;
    if (sleepy) {
      final lid = Paint()
        ..color = ColorPalette.faceInk
        ..strokeWidth = s * 0.016
        ..strokeCap = StrokeCap.round;
      for (final dx in [-0.34, 0.34]) {
        final p = Offset(c.dx + radius * dx, eyeY);
        canvas.drawArc(
          Rect.fromCenter(
            center: p,
            width: radius * 0.42,
            height: radius * 0.34,
          ),
          math.pi,
          math.pi,
          false,
          lid,
        );
      }
    } else {
      _eye(
        canvas,
        Offset(c.dx - radius * 0.33, eyeY),
        radius * 0.085,
        ColorPalette.faceInk,
        closed: blink,
      );
      _eye(
        canvas,
        Offset(c.dx + radius * 0.33, eyeY),
        radius * 0.085,
        ColorPalette.faceInk,
        closed: blink,
      );
    }

    _smile(
      canvas,
      center: Offset(c.dx, c.dy + radius * 0.16),
      width: radius * 0.52,
      height: radius * 0.26,
      color: ColorPalette.faceInk,
      strokeWidth: s * 0.016,
    );

    _blush(
      canvas,
      Offset(c.dx - radius * 0.58, c.dy + radius * 0.22),
      radius * 0.16,
      const Color(0xFFE88A5C),
    );
    _blush(
      canvas,
      Offset(c.dx + radius * 0.58, c.dy + radius * 0.22),
      radius * 0.16,
      const Color(0xFFE88A5C),
    );
  }

  // cloud
  void _paintCloud(
    Canvas canvas,
    Offset c,
    double s, {
    required Mood mood,
    bool rain = false,
    bool bolt = false,
    bool blink = false,
  }) {
    final w = s * 0.80;
    final h = w * 0.46;
    final body = switch (mood) {
      Mood.happy => const Color(0xFFFBFDFF),
      Mood.gloomy => const Color(0xFFBFCEDC),
      Mood.stormy => const Color(0xFF6E6787),
    };
    final shade = Color.lerp(body, scene.shadowColor, 0.32)!;
    final offset = Offset(c.dx, c.dy - (rain || bolt ? s * 0.035 : 0));

    // Soft drop shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: offset.translate(0, h * 0.95),
        width: w * 0.92,
        height: h * 0.5,
      ),
      Paint()
        ..color = Colors.black.fade(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Under-shadow band
    canvas.drawOval(
      Rect.fromCenter(
        center: offset.translate(0, h * 0.30),
        width: w * 0.94,
        height: h * 1.05,
      ),
      Paint()..color = shade,
    );

    // Puffs
    final puff = Paint()..color = body;
    canvas.drawOval(
      Rect.fromCenter(center: offset, width: w, height: h * 1.45),
      puff,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: offset.translate(-w * 0.27, -h * 0.44),
        width: w * 0.50,
        height: h * 1.30,
      ),
      puff,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: offset.translate(w * 0.17, -h * 0.60),
        width: w * 0.46,
        height: h * 1.22,
      ),
      puff,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: offset.translate(w * 0.33, -h * 0.16),
        width: w * 0.34,
        height: h * 1.02,
      ),
      puff,
    );

    // Face
    final faceInk = mood == Mood.stormy
        ? ColorPalette.stormFaceInk
        : ColorPalette.cloudFaceInk;
    final eyeY = offset.dy - h * 0.05;
    _eye(
      canvas,
      Offset(offset.dx - w * 0.15, eyeY),
      s * 0.021,
      faceInk,
      closed: blink,
    );
    _eye(
      canvas,
      Offset(offset.dx + w * 0.15, eyeY),
      s * 0.021,
      faceInk,
      closed: blink,
    );

    if (mood == Mood.stormy) {
      // Frowning mouth
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(offset.dx, offset.dy + h * 0.32),
          width: w * 0.24,
          height: h * 0.22,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = faceInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.016
          ..strokeCap = StrokeCap.round,
      );
    } else {
      _smile(
        canvas,
        center: Offset(offset.dx, offset.dy + h * 0.16),
        width: w * 0.22,
        height: h * 0.24,
        color: faceInk,
        strokeWidth: s * 0.016,
      );
    }

    final blushColor = mood == Mood.stormy
        ? const Color(0xFF9C8ED0)
        : const Color(0xFFF1B9A6);
    _blush(
      canvas,
      Offset(offset.dx - w * 0.27, offset.dy + h * 0.20),
      s * 0.030,
      blushColor,
    );
    _blush(
      canvas,
      Offset(offset.dx + w * 0.27, offset.dy + h * 0.20),
      s * 0.030,
      blushColor,
    );

    // Rain dangles
    if (rain) {
      final dropPaint = Paint()
        ..color = const Color(0xFF8FBBD6)
        ..strokeWidth = s * 0.016
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final x = offset.dx + (i - 1) * w * 0.22;
        final top = offset.dy + h * 0.72;
        canvas.drawLine(
          Offset(x, top),
          Offset(x - 3, top + h * 0.42),
          dropPaint,
        );
      }
    }

    // Bolt
    if (bolt) {
      final x = offset.dx + w * 0.02;
      final y = offset.dy + h * 0.70;
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x - s * 0.045, y + s * 0.085)
        ..lineTo(x + s * 0.004, y + s * 0.092)
        ..lineTo(x - s * 0.035, y + s * 0.180)
        ..lineTo(x + s * 0.055, y + s * 0.062)
        ..lineTo(x + s * 0.004, y + s * 0.056)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFE27A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 7),
      );
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFF2A8));
    }
  }

  // snowman
  void _paintSnowman(Canvas canvas, Offset c, double s, {required bool blink}) {
    final bottomR = s * 0.24;
    final midR = s * 0.18;
    final headR = s * 0.135;

    final bodyPaint = Paint()
      ..shader =
          const RadialGradient(
            center: Alignment(-0.35, -0.45),
            colors: [Colors.white, Color(0xFFEAF4FA), Color(0xFFBFD6E4)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(c.dx, c.dy + s * 0.10),
              radius: s * 0.42,
            ),
          );

    canvas.drawCircle(Offset(c.dx, c.dy + s * 0.20), bottomR, bodyPaint);
    canvas.drawCircle(Offset(c.dx, c.dy - s * 0.03), midR, bodyPaint);
    canvas.drawCircle(Offset(c.dx, c.dy - s * 0.21), headR, bodyPaint);

    // Scarf
    final scarf = Paint()..color = const Color(0xFFD9695F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy - s * 0.115),
          width: midR * 1.7,
          height: headR * 0.55,
        ),
        Radius.circular(s * 0.02),
      ),
      scarf,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + midR * 0.55, c.dy - s * 0.045),
          width: headR * 0.45,
          height: headR * 1.25,
        ),
        Radius.circular(s * 0.015),
      ),
      scarf,
    );

    // Hat
    final hat = Paint()..color = const Color(0xFF3A4A63);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy - s * 0.315),
        width: headR * 1.9,
        height: headR * 0.22,
      ),
      hat,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy - s * 0.405),
          width: headR * 1.20,
          height: headR * 0.75,
        ),
        Radius.circular(s * 0.012),
      ),
      hat,
    );

    // Face
    _eye(
      canvas,
      Offset(c.dx - headR * 0.38, c.dy - s * 0.235),
      s * 0.016,
      const Color(0xFF2C3A4B),
      closed: blink,
    );
    _eye(
      canvas,
      Offset(c.dx + headR * 0.38, c.dy - s * 0.235),
      s * 0.016,
      const Color(0xFF2C3A4B),
      closed: blink,
    );

    // Carrot nose
    final nose = Path()
      ..moveTo(c.dx - s * 0.005, c.dy - s * 0.198)
      ..lineTo(c.dx + s * 0.085, c.dy - s * 0.182)
      ..lineTo(c.dx - s * 0.005, c.dy - s * 0.168)
      ..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFFE58A43));

    // Buttons
    final button = Paint()..color = const Color(0xFF41556B);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(c.dx, c.dy + s * 0.03 + i * s * 0.045),
        s * 0.011,
        button,
      );
    }

    // Twig arms
    final twig = Paint()
      ..color = const Color(0xFF6B4A32)
      ..strokeWidth = s * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(c.dx - midR * 0.85, c.dy - s * 0.02),
      Offset(c.dx - midR * 1.65, c.dy - s * 0.10),
      twig,
    );
    canvas.drawLine(
      Offset(c.dx + midR * 0.85, c.dy - s * 0.02),
      Offset(c.dx + midR * 1.65, c.dy - s * 0.10),
      twig,
    );
  }

  // fog wisp
  void _paintFogWisp(Canvas canvas, Offset c, double s, {required bool blink}) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.fade(0.95),
          ColorPalette.fogSilver.fade(0.85),
          ColorPalette.fogSage.fade(0.55),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: s * 0.42));

    final blob = Path()
      ..moveTo(c.dx - s * 0.30, c.dy + s * 0.06)
      ..cubicTo(
        c.dx - s * 0.40,
        c.dy - s * 0.16,
        c.dx - s * 0.18,
        c.dy - s * 0.30,
        c.dx - s * 0.02,
        c.dy - s * 0.20,
      )
      ..cubicTo(
        c.dx + s * 0.12,
        c.dy - s * 0.34,
        c.dx + s * 0.38,
        c.dy - s * 0.20,
        c.dx + s * 0.30,
        c.dy + s * 0.02,
      )
      ..cubicTo(
        c.dx + s * 0.42,
        c.dy + s * 0.18,
        c.dx + s * 0.16,
        c.dy + s * 0.30,
        c.dx - s * 0.02,
        c.dy + s * 0.24,
      )
      ..cubicTo(
        c.dx - s * 0.18,
        c.dy + s * 0.32,
        c.dx - s * 0.34,
        c.dy + s * 0.22,
        c.dx - s * 0.30,
        c.dy + s * 0.06,
      )
      ..close();

    canvas.drawPath(
      blob,
      Paint()
        ..color = Colors.black.fade(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(blob, paint);

    _eye(
      canvas,
      Offset(c.dx - s * 0.10, c.dy - s * 0.02),
      s * 0.019,
      const Color(0xFF5C6C67),
      closed: blink,
    );
    _eye(
      canvas,
      Offset(c.dx + s * 0.10, c.dy - s * 0.02),
      s * 0.019,
      const Color(0xFF5C6C67),
      closed: blink,
    );
    _smile(
      canvas,
      center: Offset(c.dx, c.dy + s * 0.045),
      width: s * 0.10,
      height: s * 0.05,
      color: const Color(0xFF5C6C67),
      strokeWidth: s * 0.014,
    );

    // Wispy tail
    final tail = Paint()
      ..color = Colors.white.fade(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(c.dx + s * 0.30, c.dy + s * 0.10),
        width: s * 0.30,
        height: s * 0.22,
      ),
      -math.pi * 0.6,
      math.pi * 1.1,
      false,
      tail,
    );
  }

  // helpers
  void _eye(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    bool closed = false,
  }) {
    if (closed) {
      canvas.drawLine(
        center.translate(-radius * 1.1, 0),
        center.translate(radius * 1.1, 0),
        Paint()
          ..color = color
          ..strokeWidth = radius * 0.75
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center.translate(-radius * 0.30, -radius * 0.34),
      radius * 0.30,
      Paint()..color = Colors.white.fade(0.85),
    );
  }

  void _smile(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required Color color,
    required double strokeWidth,
  }) {
    canvas.drawArc(
      Rect.fromCenter(center: center, width: width, height: height),
      math.pi * 0.15,
      math.pi * 0.70,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  void _blush(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.fade(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant CharacterPainter oldDelegate) {
    return oldDelegate.scene.kind != scene.kind ||
        oldDelegate.scene.isNight != scene.isNight ||
        oldDelegate.motion != motion;
  }
}
