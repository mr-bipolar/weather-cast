import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/text_style.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/weather_backdrop.dart';
import 'package:weather/view/widgets/weather_characters/weather_character.dart';

class ScenePreviewScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ScenePreviewScreen> createState() => _ScenePreviewScreenState();
}

class _ScenePreviewScreenState extends State<ScenePreviewScreen> {
  static const List<String> _conditions = [
    'Clear',
    'Clouds',
    'Drizzle',
    'Rain',
    'Thunderstorm',
    'Snow',
    'Mist',
    'Fog',
    'Haze',
    'Smoke',
    'Dust',
    'Sand',
    'Ash',
    'Squall',
    'Tornado',
  ];

  int _index = 0;
  bool _isNight = false;

  WeatherScene get _scene =>
      WeatherScene.resolve(condition: _conditions[_index], isNight: _isNight);

  void _step(int delta) {
    final count = _conditions.length;
    setState(() => _index = (_index + delta + count) % count);
  }

  static String _kindName(WeatherSceneTypes kind) {
    switch (kind) {
      case WeatherSceneTypes.clear:
        return 'Clear';
      case WeatherSceneTypes.clouds:
        return 'Clouds';
      case WeatherSceneTypes.rain:
        return 'Rain';
      case WeatherSceneTypes.thunderstorm:
        return 'Thunderstorm';
      case WeatherSceneTypes.snow:
        return 'Snow';
      case WeatherSceneTypes.fog:
        return 'Fog';
      case WeatherSceneTypes.haze:
        return 'Haze';
      case WeatherSceneTypes.storm:
        return 'Storm';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final scene = _scene;
    final label = _conditions[_index];
    final resolved = _kindName(scene.kind);
    final isAlias = resolved.toLowerCase() != label.toLowerCase();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final subtitle = <String>[
      if (isAlias) 'plays the $resolved scene' else '$resolved scene',
      _isNight ? 'Night' : 'Day',
    ].join(' · ');

    final content = WeatherBackdrop(
      scene: scene,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            children: [
              _topBar(context),
              const Spacer(),
              WeatherCharacter(scene: scene, size: 190),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: ColorPalette.ink,
                  fontSize: 30,
                  fontWeight: .w300,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: .ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: CustomTextStyle.caption.copyWith(fontSize: 11.5),
                textAlign: .center,
              ),
              const SizedBox(height: 20),
              _navRow(),
              const SizedBox(height: 12),
              _dayNightRow(),
              if (reduceMotion) ...[
                const SizedBox(height: 14),
                const _ReducedMotionNotice(),
              ],
            ],
          ),
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(child: content)
        : Scaffold(body: content);
  }

  Widget _dayNightRow() => Container(
    padding: const .all(4),
    decoration: BoxDecoration(
      color: Colors.white.fade(0.12),
      borderRadius: .circular(16),
      border: .all(color: Colors.white.fade(0.16)),
    ),
    child: Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'Day',
            selected: !_isNight,
            onTap: () => setState(() => _isNight = false),
          ),
        ),
        Expanded(
          child: _ModeChip(
            label: 'Night',
            selected: _isNight,
            onTap: () => setState(() => _isNight = true),
          ),
        ),
      ],
    ),
  );

  Widget _navRow() => Row(
    children: [
      Expanded(
        child: _NavButton(
          label: 'Previous',
          leadingIcon: Icons.chevron_left,
          semanticLabel: 'Previous scene',
          onTap: () => _step(-1),
        ),
      ),
      Padding(
        padding: const .symmetric(horizontal: 12),
        child: Text(
          '${_index + 1} / ${_conditions.length}',
          style: CustomTextStyle.caption.copyWith(fontSize: 11),
        ),
      ),
      Expanded(
        child: _NavButton(
          label: 'Next',
          trailingIcon: Icons.chevron_right,
          semanticLabel: 'Next scene',
          onTap: () => _step(1),
        ),
      ),
    ],
  );
}

Widget _topBar(BuildContext context) => Row(
  children: [
    _CircleButton(
      icon: Icons.arrow_back,
      semanticLabel: 'Back to weather',
      onTap: () => Navigator.of(context).maybePop(),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Scene preview', style: CustomTextStyle.location),
          Text(
            'Developer tool · debug build',
            style: CustomTextStyle.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    ),
    Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.fade(0.22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        'DEBUG',
        style: CustomTextStyle.metricLabel.copyWith(
          color: Colors.white,
          fontSize: 9,
          letterSpacing: 1.2,
        ),
      ),
    ),
  ],
);

/// Circular back affordance that works on both Material and Cupertino roots.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: .opaque,
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: .circle,
            color: Colors.white.fade(0.16),
            border: Border.all(color: Colors.white.fade(0.20)),
          ),
          child: Icon(icon, size: 20, color: ColorPalette.ink),
        ),
      ),
    );
  }
}

/// Shown when the device or OS asks for reduced motion.
class _ReducedMotionNotice extends StatelessWidget {
  const _ReducedMotionNotice();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        mainAxisAlignment: .center,
        children: [
          const Icon(
            Icons.motion_photos_off_outlined,
            size: 14,
            color: ColorPalette.muted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Animations paused by system setting',
              style: CustomTextStyle.caption.copyWith(fontSize: 10.5),
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Day / Night segmented choice.
class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: .opaque,
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: .center,
          decoration: BoxDecoration(
            color: selected ? Colors.white.fade(0.24) : Colors.transparent,
            borderRadius: .circular(12),
          ),
          child: Text(
            label,
            style: CustomTextStyle.railTime.copyWith(
              fontSize: 11.5,
              color: selected ? ColorPalette.ink : ColorPalette.muted,
              fontWeight: .w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small labelled pill used for scene navigation.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: .opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const .symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.fade(0.14),
            borderRadius: .circular(14),
            border: Border.all(color: Colors.white.fade(0.18)),
          ),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: ColorPalette.ink),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  label,
                  style: CustomTextStyle.railTemp.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 2),
                Icon(trailingIcon, size: 18, color: ColorPalette.ink),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
