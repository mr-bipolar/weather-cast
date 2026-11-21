import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/view/widgets/custom_painters/splash_painter.dart';

class SplashLightScene extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorPalette.nightTop,
                Color(0xFF101731),
                Color(0xFF0A0E1F),
                ColorPalette.nightBottom,
              ],
              stops: [0.0, 0.45, 0.72, 1.0],
            ),
          ),
        ),
        const Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: SplashPainter())),
        ),
        SafeArea(
          child: Align(
            alignment: const Alignment(0, -0.08),
            child: Semantics(
              container: true,
              label: AppStrings.appName,
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Image.asset(
                      AppStrings.appIconPath,
                      height: 104,
                      filterQuality: .medium,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppStrings.appName,
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xDBF7F8FB),
                        fontSize: 12.5,
                        fontWeight: .w600,
                        letterSpacing: 5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
