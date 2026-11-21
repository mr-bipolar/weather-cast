import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/model/weather_model.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/theme/system_overlay.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/offline_overlay.dart';
import 'package:weather/view/widgets/weather_backdrop.dart';
import 'package:weather/view/widgets/weather_view/main_screen.dart';

class MainScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Network connection
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;

  // Atmosphere
  final WeatherScene _scene = const WeatherScene(
    kind: WeatherSceneTypes.clear,
    isNight: false,
  );

  // Weather data
  String? cityname,
      weather,
      conditionDescription,
      temperature,
      maxtemp,
      mintemp,
      feelslike,
      sunrise,
      sunset,
      humidity,
      visibility,
      visibilityUnit,
      presure,
      windspeed,
      windDirection;

  // Helpers
  final bool _toAvoidBottomInset = false;
  final List<ForecastItem> _forecastItems = const [];
  int? _forecastTimezone;

  final bool _isLoading = false;
  String? _loadError;
  DateTime? _lastUpdated;

  // Search controller
  late final TextEditingController _textEditingController;

  // Device location permission and service checks for initial device load.
  Future<bool> _deviceLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _loadError = AppStrings.permissionDenied);
        }
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _loadError = AppStrings.permanentlyDenied);
        }
        return false;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _loadError = AppStrings.permissionDisabled);
        }
        return false;
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (mounted) {
          setState(() => _loadError = AppStrings.permissionUnavailable);
        }
        return false;
      }

      return true;
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = AppStrings.unableAccess);
      }
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Device location
    _deviceLocation();

    _textEditingController = TextEditingController();

    _streamSubscription = InternetConnection().onStatusChange.listen((event) {
      if (!mounted) return;

      switch (event) {
        case InternetStatus.connected:
          final wasConnected = _isConnected;
          setState(() => _isConnected = true);
          final lastUpdate = _lastUpdated;
          final needsRefresh =
              _loadError != null ||
              (lastUpdate != null &&
                  DateTime.now().difference(lastUpdate) >
                      const Duration(minutes: 30));
          if (mounted && !wasConnected && needsRefresh) {}
          break;

        case InternetStatus.disconnected:
          setState(() => _isConnected = false);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainView = MainScreenView(
      textEditingController: _textEditingController,
      scene: _scene,
      isConnected: _isConnected,
      isLoading: _isLoading,
      loadError: _loadError,
      cityname: cityname,
      temperature: temperature,
      conditionDescription: conditionDescription,
      weather: weather,
      maxtemp: maxtemp,
      mintemp: mintemp,
      feelslike: feelslike,
      sunrise: sunrise,
      sunset: sunset,
      lastUpdated: _lastUpdated,
      pressure: presure,
      humidity: humidity,
      visibility: visibility,
      visibilityUnit: visibilityUnit,
      windspeed: windspeed,
      windDirection: windDirection,
      forecastItems: _forecastItems,
      forecastTimezone: _forecastTimezone,
    );

    final content = Platform.isIOS
        ? CupertinoPageScaffold(
            resizeToAvoidBottomInset: _toAvoidBottomInset,
            child: Stack(
              children: [
                WeatherBackdrop(scene: _scene, child: mainView),
                OfflineOverlay(isOffline: _isConnected),
              ],
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: _toAvoidBottomInset,
            body: Stack(
              children: [
                WeatherBackdrop(scene: _scene, child: mainView),
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
    _textEditingController.dispose();
    super.dispose();
  }
}
