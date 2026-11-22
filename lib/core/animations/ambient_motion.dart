import 'package:flutter/material.dart';

class AmbientMotion extends InheritedWidget {
  const new({
    super.key,
    required this.phase,
    required this.enabled,
    required super.child,
  });

  /// 0 → 1 over the ambient cycle (30 s).
  final Animation<double> phase;

  /// False when the platform or the user asked for reduced motion.
  final bool enabled;

  /// Returns the ambient phase, or null when no [AmbientMotion] is above.
  static Animation<double>? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AmbientMotion>()?.phase;
  }

  /// Whether ambient animation is currently allowed.
  static bool enabledOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AmbientMotion>()
            ?.enabled ??
        false;
  }

  @override
  bool updateShouldNotify(AmbientMotion oldWidget) {
    return oldWidget.phase != phase || oldWidget.enabled != enabled;
  }
}

/// Shared helpers for time-based, allocation-light motion maths.
class Ambient {
  Ambient._();

  /// Wraps [value] into the range `[min, max)`.
  static double wrap(double value, double min, double max) {
    final span = max - min;
    final wrapped = (value - min) % span;
    return min + (wrapped < 0 ? wrapped + span : wrapped);
  }

  /// Periodic 0 → 1 pulse position, offset per [seed].
  static double cycle(double t, double speed, [double seed = 0]) {
    return wrap(t * speed + seed, 0, 1);
  }
}
