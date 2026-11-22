import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather/service/weather_services.dart';

void main() {
  group('WeatherServices', () {
    test('getWeather returns null for an HTTP error', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'api.openweathermap.org');
        expect(request.url.path, '/data/2.5/weather');
        expect(request.url.queryParameters['q'], 'London');

        return http.Response('Not found', 404);
      });

      final service = WeatherServices(client: client);

      expect(await service.getWeather('London'), isNull);

      client.close();
    });

    test('getForecast returns null for an HTTP error', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/data/2.5/forecast');
        expect(request.url.queryParameters['q'], 'London');

        return http.Response('Server error', 500);
      });

      final service = WeatherServices(client: client);

      expect(await service.getForecast('London'), isNull);

      client.close();
    });

    test('getWeather returns null for invalid JSON', () async {
      final client = MockClient((request) async {
        return http.Response('invalid json', 200);
      });

      final service = WeatherServices(client: client);

      expect(await service.getWeather('London'), isNull);

      client.close();
    });

    test('getForecast returns null for invalid JSON', () async {
      final client = MockClient((request) async {
        return http.Response('invalid json', 200);
      });

      final service = WeatherServices(client: client);

      expect(await service.getForecast('London'), isNull);

      client.close();
    });

    test('getWeather returns null when the network request fails', () async {
      final client = MockClient((request) async {
        throw Exception('No internet connection');
      });

      final service = WeatherServices(client: client);

      expect(await service.getWeather('London'), isNull);

      client.close();
    });

    test('getForecast returns null when the network request fails', () async {
      final client = MockClient((request) async {
        throw Exception('No internet connection');
      });

      final service = WeatherServices(client: client);

      expect(await service.getForecast('London'), isNull);

      client.close();
    });
  });

  test('getWeather parses a successful response', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'name': 'London',
          'timezone': 0,
          'visibility': 10000,
          'weather': [
            {'id': 800, 'main': 'Clear', 'description': 'clear sky'},
          ],
          'main': {
            'temp': 18.5,
            'temp_min': 16.0,
            'temp_max': 20.0,
            'feels_like': 18.0,
            'pressure': 1013,
            'humidity': 55,
          },
          'wind': {'speed': 3.2, 'deg': 270},
          'sys': {'sunrise': 1700000000, 'sunset': 1700040000},
        }),
        200,
      );
    });

    final service = WeatherServices(client: client);

    final result = await service.getWeather('London');

    expect(result, isNotNull);
    expect(result!.name, 'London');
    expect(result.main.temp, 18.5);
    expect(result.main.humidity, 55);
    expect(result.weather.first.main, 'Clear');
    expect(result.weather.first.description, 'clear sky');
    expect(result.wind.speed, 3.2);
    expect(result.visibility, 10000);
    expect(result.timezone, 0);

    client.close();
  });

  test('getForecast parses a successful response', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'city': {'timezone': 19800},
          'list': [
            {
              'dt': 1795348800,
              'main': {'temp': 29.5, 'feels_like': 31.0},
              'weather': [
                {
                  'id': 800,
                  'main': 'Clear',
                  'description': 'clear sky',
                  'icon': '01d',
                },
              ],
              'sys': {'pod': 'd'},
            },
          ],
        }),
        200,
      );
    });

    final service = WeatherServices(client: client);

    final result = await service.getForecast('Thiruvananthapuram');

    expect(result, isNotNull);
    expect(result!.timezone, 19800);
    expect(result.items, hasLength(1));
    expect(result.items.first.temp, 29.5);
    expect(result.items.first.feelsLike, 31.0);
    expect(result.items.first.condition, 'Clear');
    expect(result.items.first.description, 'clear sky');
    expect(result.items.first.conditionId, 800);
    expect(result.items.first.isNight, false);

    client.close();
  });
}
