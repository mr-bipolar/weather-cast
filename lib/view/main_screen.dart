import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/theme/system_overlay.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/offline_overlay.dart';
import 'package:weather/view/widgets/weather_backdrop.dart';

class MainScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Net connection checker
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;

  // Helpers
  final bool _toAvoidBottomInset = false;

  // Atmosphere
  final WeatherScene _scene = const WeatherScene(
    kind: WeatherSceneTypes.clear,
    isNight: false,
  );

  @override
  void initState() {
    super.initState();

    // Internet connection check
    _streamSubscription = InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          if (mounted) setState(() => _isConnected = true);
          break;
        case InternetStatus.disconnected:
          if (mounted) setState(() => _isConnected = false);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Platform.isIOS
        ? CupertinoPageScaffold(
            resizeToAvoidBottomInset: _toAvoidBottomInset,
            child: Stack(
              children: [
                WeatherBackdrop(scene: _scene, child: Text('hello')),
                OfflineOverlay(isOffline: _isConnected),
              ],
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: _toAvoidBottomInset,
            body: Stack(
              children: [
                WeatherBackdrop(scene: _scene, child: Text('hello')),
                OfflineOverlay(isOffline: _isConnected),
              ],
            ),
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.statusBarStyle(_scene),
      child: content,
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
