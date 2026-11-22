import 'package:flutter/cupertino.dart';
import 'package:weather/core/animations/ambient_motion.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/scene_layers.dart';

class WeatherBackdrop extends StatefulWidget {
  final WeatherScene scene;
  final Widget child;

  const new({super.key, required this.scene, required this.child});

  @override
  State<WeatherBackdrop> createState() => _WeatherBackdropState();
}

class _WeatherBackdropState extends State<WeatherBackdrop>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Animation
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  bool _reduceMotion = false;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _motion.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      _sync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _sync();
  }

  /// Applies lifecycle + reduced-motion rules to the shared controller.
  void _sync() {
    final shouldAnimate =
        !_reduceMotion && _lifecycle == AppLifecycleState.resumed;

    if (!shouldAnimate) {
      if (_motion.isAnimating) _motion.stop();
      if (_reduceMotion) _motion.value = 0;
      return;
    }

    if (!_motion.isAnimating) _motion.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final key = ValueKey('${scene.kind.index}-${scene.isNight}');

    return AmbientMotion(
      phase: _motion,
      enabled: !_reduceMotion,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: _reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 700),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: KeyedSubtree(
              key: key,
              child: SceneLayers(scene: scene, motion: _motion),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }
}
