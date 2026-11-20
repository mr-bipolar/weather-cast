import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:weather/core/animations/ambient_motion.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/theme/weather_scene.dart';

class SceneMotionPainter extends CustomPainter {
  SceneMotionPainter({required this.scene, required Animation<double> motion})
    : _motion = motion,
      _clouds = _buildClouds(scene),
      _drops = _buildDrops(scene),
      _flakes = _buildFlakes(scene),
      super(repaint: motion);

  final WeatherScene scene;
  final Animation<double> _motion;
  final List<_Cloud> _clouds;
  final List<Offset> _drops;
  final List<_Flake> _flakes;

  /// Cached cloud paints, rebuilt only when the canvas width changes.
  double? _brushWidth;
  List<_CloudBrush> _brushes = const [];

  double get _t => _motion.value;

  static List<_Cloud> _buildClouds(WeatherScene scene) {
    switch (scene.kind) {
      case WeatherSceneTypes.clear:
        return const [
          _Cloud(0.22, 0.17, 0.30, 0.55),
          _Cloud(0.86, 0.25, 0.24, 0.38),
        ];
      case WeatherSceneTypes.clouds:
        return const [
          _Cloud(0.20, 0.16, 0.42, 0.90),
          _Cloud(0.78, 0.23, 0.36, 0.70),
          _Cloud(0.46, 0.33, 0.50, 0.55),
        ];
      case WeatherSceneTypes.rain:
        return const [
          _Cloud(0.26, 0.15, 0.48, 0.95),
          _Cloud(0.80, 0.21, 0.42, 0.85),
          _Cloud(0.50, 0.30, 0.56, 0.70),
        ];
      case WeatherSceneTypes.thunderstorm:
      case WeatherSceneTypes.storm:
        return const [
          _Cloud(0.18, 0.14, 0.52, 1.0),
          _Cloud(0.82, 0.19, 0.46, 0.95),
          _Cloud(0.48, 0.29, 0.62, 0.85),
        ];
      case WeatherSceneTypes.snow:
        return const [
          _Cloud(0.24, 0.15, 0.44, 0.85),
          _Cloud(0.80, 0.22, 0.38, 0.7),
        ];
      case WeatherSceneTypes.fog:
        return const [
          _Cloud(0.30, 0.20, 0.52, 0.55),
          _Cloud(0.74, 0.30, 0.48, 0.45),
        ];
      case WeatherSceneTypes.haze:
        return const [
          _Cloud(0.34, 0.22, 0.40, 0.45),
          _Cloud(0.78, 0.34, 0.34, 0.35),
        ];
    }
  }

  static List<Offset> _buildDrops(WeatherScene scene) {
    if (scene.kind != WeatherSceneTypes.rain &&
        scene.kind != WeatherSceneTypes.thunderstorm &&
        scene.kind != WeatherSceneTypes.storm) {
      return const [];
    }
    final rng = math.Random(41 + scene.kind.index);
    return List.generate(46, (_) {
      return Offset(rng.nextDouble(), rng.nextDouble());
    });
  }

  static List<_Flake> _buildFlakes(WeatherScene scene) {
    if (scene.kind != WeatherSceneTypes.snow) return const [];
    final rng = math.Random(77);
    return List.generate(60, (_) {
      return _Flake(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 1.2 + rng.nextDouble() * 2.4,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = _t;
    _ensureBrushes(size.width);

    _paintClouds(canvas, size, t);

    switch (scene.kind) {
      case WeatherSceneTypes.rain:
        _paintRain(canvas, size, t);
        break;
      case WeatherSceneTypes.thunderstorm:
        _paintRain(canvas, size, t);
        final flash = _flashAt(t);
        _paintBolt(canvas, size, flash);
        if (flash > 0) {
          canvas.drawRect(
            Offset.zero & size,
            Paint()..color = Colors.white.withValues(alpha: 0.10 * flash),
          );
        }
        break;
      case WeatherSceneTypes.storm:
        _paintRain(canvas, size, t);
        _paintWindStreaks(canvas, size, t);
        _paintBolt(canvas, size, 0);
        break;
      case WeatherSceneTypes.snow:
        _paintSnow(canvas, size, t);
        break;
      case WeatherSceneTypes.fog:
        _paintFogBands(canvas, size, t);
        break;
      case WeatherSceneTypes.haze:
        _paintShimmer(canvas, size, Offset.zero & size, t);
        break;
      case WeatherSceneTypes.clear:
      case WeatherSceneTypes.clouds:
        break;
    }
  }

  void _ensureBrushes(double width) {
    if (_brushWidth == width) return;
    _brushWidth = width;

    final base = scene.isNight
        ? Color.lerp(scene.gradient[1], Colors.white, 0.16)!
        : Color.lerp(scene.gradient[0], Colors.white, 0.34)!;
    final shaded = Color.lerp(base, scene.shadowColor, 0.30)!;

    _brushes = [
      for (final cloud in _clouds)
        _CloudBrush(
          paint: Paint()
            ..color = base.withValues(alpha: 0.55 + 0.35 * cloud.opacity)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              width * cloud.scale * 0.035,
            ),
          lowerPaint: Paint()
            ..color = shaded.withValues(alpha: 0.45 * cloud.opacity)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              width * cloud.scale * 0.045,
            ),
        ),
    ];
  }

  //* Slow parallax drift. Larger clouds travel one screen per cycle, smaller
  //* ones two, so the loop stays seamless when the controller restarts.
  void _paintClouds(Canvas canvas, Size size, double t) {
    for (var i = 0; i < _clouds.length; i++) {
      final cloud = _clouds[i];
      final brush = _brushes[i];
      final speed = cloud.scale >= 0.45 ? 1.0 : 2.0;
      final phase = Ambient.wrap(cloud.x + t * speed, 0, 1);
      final width = size.width * cloud.scale;
      final height = width * 0.30 * cloud.puff;

      for (var copy = -1; copy <= 1; copy++) {
        final cx = (phase + copy) * size.width;
        //* Cull copies fully outside the canvas.
        if (cx < -width * 0.6 || cx > size.width + width * 0.6) continue;

        final center = Offset(cx, cloud.y * size.height);

        canvas.drawOval(
          Rect.fromCenter(
            center: center.translate(0, height * 0.42),
            width: width * 0.92,
            height: height * 0.86,
          ),
          brush.lowerPaint,
        );

        _drawPuffs(canvas, brush.paint, center, width, height);
      }
    }
  }

  void _drawPuffs(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height,
  ) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height * 1.5),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-width * 0.26, -height * 0.42),
        width: width * 0.52,
        height: height * 1.35,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(width * 0.20, -height * 0.58),
        width: width * 0.46,
        height: height * 1.15,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(width * 0.34, -height * 0.18),
        width: width * 0.34,
        height: height * 0.95,
      ),
      paint,
    );
  }

  /// Gentle rain with a slight wind slant; loops every cycle.
  void _paintRain(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = const Color(0xFFCFE4F0).withValues(alpha: 0.38)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (final drop in _drops) {
      final y = Ambient.wrap(drop.dy + t * 3, 0, 1);
      final x = Ambient.wrap(drop.dx + t, 0, 1);
      final top = Offset(x * size.width, y * size.height);
      canvas.drawLine(top, top.translate(-5, 20), paint);
    }
  }

  /// Occasional double-pulse flash, three times per 30 s cycle.
  double _flashAt(double t) {
    const starts = [0.18, 0.55, 0.82];
    for (final start in starts) {
      final d = t - start;
      if (d < 0 || d > 0.045) continue;
      final p = d / 0.045;
      final pulse = math.sin(p * math.pi * 2) * (1 - p);
      return pulse.abs().clamp(0.0, 1.0);
    }
    return 0;
  }

  void _paintBolt(Canvas canvas, Size size, double flash) {
    final x = size.width * 0.62;
    final y = size.height * 0.30;
    final bolt = Path()
      ..moveTo(x, y)
      ..lineTo(x - size.width * 0.045, y + size.height * 0.07)
      ..lineTo(x + size.width * 0.005, y + size.height * 0.075)
      ..lineTo(x - size.width * 0.035, y + size.height * 0.15)
      ..lineTo(x + size.width * 0.055, y + size.height * 0.055)
      ..lineTo(x + size.width * 0.004, y + size.height * 0.05)
      ..close();

    canvas.drawPath(
      bolt,
      Paint()
        ..color = const Color(0xFFFFE27A)
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, 6 + flash * 6),
    );
    canvas.drawPath(bolt, Paint()..color = const Color(0xFFFFF3B8));
  }

  /// Restrained wind streaks for squall/tornado scenes.
  void _paintWindStreaks(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 6; i++) {
      final phase = Ambient.wrap(i * 0.17 + t, 0, 1);
      final y = size.height * (0.24 + i * 0.095);
      final length = size.width * 0.20;
      final startX = phase * size.width;
      for (var copy = -1; copy <= 1; copy++) {
        final x = startX + copy * size.width;
        if (x > size.width || x + length < 0) continue;
        canvas.drawLine(Offset(x, y), Offset(x + length, y - 3), paint);
      }
    }
  }

  void _paintSnow(Canvas canvas, Size size, double t) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.78);

    for (final flake in _flakes) {
      final sway = math.sin((t * 6 + flake.x) * math.pi * 2) * 0.012;
      final x = Ambient.wrap(flake.x + sway, 0, 1);
      final y = Ambient.wrap(flake.y + t * 2, 0, 1);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        flake.radius,
        paint,
      );
    }
  }

  void _paintFogBands(Canvas canvas, Size size, double t) {
    for (var i = 0; i < 3; i++) {
      final drift = math.sin((t + i * 0.18) * math.pi * 2) * 0.06;
      final pulse =
          0.16 - i * 0.035 + 0.02 * math.sin((t * 2 + i * 0.3) * math.pi * 2);
      final y = size.height * (0.42 + i * 0.13);
      final band = Rect.fromCenter(
        center: Offset(size.width * (0.5 - i * 0.05 + drift), y),
        width: size.width * 1.25,
        height: size.height * (0.09 + i * 0.02),
      );
      canvas.drawOval(
        band,
        Paint()
          ..color = Colors.white.withValues(alpha: pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  void _paintShimmer(Canvas canvas, Size size, Rect rect, double t) {
    final shift = math.sin(t * math.pi * 2) * 0.04;
    final pulse = 0.085 + 0.03 * math.sin(t * math.pi * 4);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1 + shift, -1),
          end: const Alignment(1, 1),
          colors: [
            scene.glowColor.withValues(alpha: 0.18),
            Colors.transparent,
            scene.glowColor.withValues(alpha: 0.10),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.30 + shift), size.height * 0.52),
        width: size.width * 0.9,
        height: size.height * 0.12,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
  }

  @override
  bool shouldRepaint(covariant SceneMotionPainter oldDelegate) {
    return oldDelegate.scene.kind != scene.kind ||
        oldDelegate.scene.isNight != scene.isNight ||
        oldDelegate._motion != _motion;
  }
}

@immutable
class _Cloud {
  const _Cloud(this.x, this.y, this.scale, this.opacity);

  final double x;
  final double y;
  final double scale;
  final double opacity;

  double get puff => 0.9 + opacity * 0.35;
}

class _CloudBrush {
  const _CloudBrush({required this.paint, required this.lowerPaint});

  final Paint paint;
  final Paint lowerPaint;
}

@immutable
class _Flake {
  const _Flake({required this.x, required this.y, required this.radius});

  final double x;
  final double y;
  final double radius;
}
