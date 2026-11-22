import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/env/env.dart';
import 'package:weather/model/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  WeatherServices({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  final String _apiKey = Env.weatherKey;
  final String _host = 'https://api.openweathermap.org/data/2.5/weather';
  final String _forecastHost =
      'https://api.openweathermap.org/data/2.5/forecast';

  static const Duration _httpTimeout = Duration(seconds: 15);
  static const Duration _locationTimeout = Duration(seconds: 30);

  Future<Position>? _positionFuture;

  Future<Position> _devicePosition() {
    return _positionFuture ??= _fetchDevicePosition();
  }

  Future<Position> _fetchDevicePosition() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return Geolocator.getCurrentPosition(locationSettings: locationSettings)
        .timeout(_locationTimeout);
  }

  // Current weather by city.
  Future<WeatherData?> getWeather(String cityName) async {
    try {
      final response = await _client
          .get(Uri.parse('$_host?q=$cityName&appid=$_apiKey&units=metric'))
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(response.body));
      }

      throw Exception('Data not found..! (HTTP ${response.statusCode})');
    } catch (e) {
      debugPrint('Log => GetWeather : $e');
      return null;
    }
  }

  // Current weather by device location.
  Future<WeatherData?> weather() async {
    try {
      final position = await _devicePosition();

      final response = await _client
          .get(
            Uri.parse(
              '$_host?lat=${position.latitude}'
              '&lon=${position.longitude}'
              '&appid=$_apiKey&units=metric',
            ),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(response.body));
      }

      throw Exception('Data not found..! (HTTP ${response.statusCode})');
    } catch (e) {
      debugPrint('Log => weather : $e');
      return null;
    }
  }

  // Forecast by city.
  Future<ForecastData?> getForecast(String cityName) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_forecastHost?q=$cityName&appid=$_apiKey&units=metric'),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        return ForecastData.fromJson(jsonDecode(response.body));
      }

      throw Exception('Forecast not found..! (HTTP ${response.statusCode})');
    } catch (e) {
      debugPrint('Log => GetForecast : $e');
      return null;
    }
  }

  // Forecast by device location.
  Future<ForecastData?> forecast() async {
    try {
      final position = await _devicePosition();

      final response = await _client
          .get(
            Uri.parse(
              '$_forecastHost?lat=${position.latitude}'
              '&lon=${position.longitude}'
              '&appid=$_apiKey&units=metric',
            ),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        return ForecastData.fromJson(jsonDecode(response.body));
      }

      throw Exception('Forecast not found..! (HTTP ${response.statusCode})');
    } catch (e) {
      debugPrint('Log => forecast : $e');
      return null;
    }
  }

  // Close only the client created internally by this service.
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
