import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/model/weather_model.dart';
import 'package:weather/service/weather_services.dart';
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
  WeatherScene _scene = const WeatherScene(
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
  List<ForecastItem> _forecastItems = const [];
  int? _forecastTimezone;

  bool _isLoading = false;
  String? _loadError;
  DateTime? _lastUpdated;
  int _requestSeq = 0;
  String _lastRequestedCity = '';

  // Search controller
  late final TextEditingController _textEditingController;

  // Api call function
  Future<void> _getWeatherData(String city) async {
    final seq = ++_requestSeq;
    _lastRequestedCity = city;

    // service call
    WeatherServices weatherServices = WeatherServices();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final WeatherData? weatherModel;

      if (city.isEmpty) {
        weatherModel = await weatherServices.weather();
      } else {
        weatherModel = await weatherServices.getWeather(city);
      }

      var currentUpdated = false;

      if (weatherModel != null) {
        final model = weatherModel;
        final isNight = WeatherScene.nightAt(
          sunrise: model.sys.sunrise,
          sunset: model.sys.sunset,
        );
        final current = model.weather.isNotEmpty ? model.weather.first : null;
        final visMeters = model.visibility;

        if (!mounted || seq != _requestSeq) return;
        // set api value to ui strings
        setState(() {
          cityname = model.name;
          weather = current?.main;
          conditionDescription = current?.description;
          temperature = model.main.temp.round().toString();
          maxtemp = model.main.tempMax.round().toString();
          mintemp = model.main.tempMin.round().toString();
          feelslike = model.main.feelsLike?.round().toString();
          sunrise = model.timezone == null
              ? null
              : DateFormat('hh:mm a')
                    .format(_cityLocalTime(model.sys.sunrise, model.timezone));
          sunset = model.timezone == null
              ? null
              : DateFormat('hh:mm a')
                    .format(_cityLocalTime(model.sys.sunset, model.timezone));
          humidity = model.main.humidity.toString();
          visibility = visMeters >= 1000
              ? (visMeters / 1000).toStringAsFixed(1)
              : visMeters.toString();
          visibilityUnit = visMeters >= 1000 ? 'km' : 'm';
          presure = model.main.pressure.toString();
          windspeed = model.wind.speed?.toStringAsFixed(1);
          windDirection = _compassDirection(model.wind.deg);
          _lastUpdated = DateTime.now();
          _scene = WeatherScene.resolve(
            condition: current?.main,
            conditionId: current?.id,
            isNight: isNight,
          );
        });
        currentUpdated = true;
      }

      // Forecast  (city or device location)
      final ForecastData? forecastData = city.isEmpty
          ? await weatherServices.forecast()
          : await weatherServices.getForecast(city);

      if (!mounted || seq != _requestSeq) return;
      setState(() {
        if (currentUpdated) {
          if (forecastData != null) {
            _forecastItems = forecastData.items;
            _forecastTimezone = forecastData.timezone;
          } else {
            _forecastItems = const [];
            _forecastTimezone = null;
            _loadError = AppStrings.forcastUnavailable;
          }
        }

        if (weatherModel == null) {
          _loadError = city.isEmpty
              ? AppStrings.unableLoadWeather
              : 'Unable to load weather for "$city"';
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _loadError = city.isEmpty
            ? AppStrings.unableLoadWeather
            : 'Unable to load weather for "$city"';
        _isLoading = false;
      });
    }
  }

  // Device location permission and service check.
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
      await _getWeatherData('');
      return true;
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = AppStrings.unableAccess);
      }
      _isLoading = false;
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    // Device location permission and service checks for initial device load.
    _deviceLocation();

    _textEditingController = TextEditingController();

    // Network connection listener
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
          if (mounted && !wasConnected && needsRefresh) {
            _getWeatherData(_lastRequestedCity);
          }
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
      onChanged: (value) => _getWeatherData(value.trim()),
      onRetry: () => _getWeatherData(_lastRequestedCity),
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
      value: SystemOverlay.style(_scene),
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

// Helper functions
DateTime _cityLocalTime(int epochSeconds, int? offsetSeconds) {
  final utc = DateTime.fromMillisecondsSinceEpoch(
    epochSeconds * 1000,
    isUtc: true,
  );
  return offsetSeconds == null
      ? utc
      : utc.add(Duration(seconds: offsetSeconds));
}

String? _compassDirection(int? degrees) {
  if (degrees == null) return null;
  const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return points[((degrees % 360) + 22.5) ~/ 45 % 8];
}
