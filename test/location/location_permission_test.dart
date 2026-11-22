import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/view/main_screen.dart';

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  LocationPermission permission = LocationPermission.denied;
  LocationPermission requestedPermission = LocationPermission.denied;
  bool serviceEnabled = true;

  int requestCount = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requestCount++;
    return requestedPermission;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;
}

void main() {
  late FakeGeolocatorPlatform fakeGeolocator;
  late GeolocatorPlatform originalGeolocator;

  setUp(() {
    originalGeolocator = GeolocatorPlatform.instance;

    fakeGeolocator = FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = fakeGeolocator;
  });

  tearDown(() {
    GeolocatorPlatform.instance = originalGeolocator;
  });

  Future<void> pumpMainScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(
          connectionStatusStream: const Stream<InternetStatus>.empty(),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('shows permission denied when request is denied', (tester) async {
    fakeGeolocator.permission = LocationPermission.denied;
    fakeGeolocator.requestedPermission = LocationPermission.denied;

    await pumpMainScreen(tester);

    expect(fakeGeolocator.requestCount, 1);
    expect(find.text(AppStrings.permissionDenied), findsOneWidget);
  });

  testWidgets('shows permanently denied message', (tester) async {
    fakeGeolocator.permission = LocationPermission.deniedForever;

    await pumpMainScreen(tester);

    expect(fakeGeolocator.requestCount, 0);
    expect(find.text(AppStrings.permanentlyDenied), findsOneWidget);
  });

  testWidgets('shows disabled location service message', (tester) async {
    fakeGeolocator.permission = LocationPermission.whileInUse;
    fakeGeolocator.serviceEnabled = false;

    await pumpMainScreen(tester);

    expect(find.text(AppStrings.permissionDisabled), findsOneWidget);
  });

  testWidgets('shows unavailable permission message', (tester) async {
    fakeGeolocator.permission = LocationPermission.unableToDetermine;

    await pumpMainScreen(tester);

    expect(find.text(AppStrings.permissionUnavailable), findsOneWidget);
  });
}
