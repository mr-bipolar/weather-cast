import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/view/main_screen.dart';
import 'package:weather/view/widgets/splash_light_scene.dart';

class SplashScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _hold = Duration(milliseconds: 1800);
  static const Duration _fade = Duration(milliseconds: 420);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_hold, _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: reduceMotion ? Duration.zero : _fade,
        reverseTransitionDuration: reduceMotion ? Duration.zero : _fade,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    const scene = SplashLightScene();
    final content = reduceMotion
        ? scene
        : const _Entrance(child: SplashLightScene());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Platform.isIOS
          ? CupertinoPageScaffold(
              backgroundColor: ColorPalette.nightBottom,
              child: content,
            )
          : Scaffold(backgroundColor: ColorPalette.nightBottom, body: content),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// A simple entrance animation for the splash screen content.
// The content fades in and slides up slightly.

class _Entrance extends StatelessWidget {
  const _Entrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
