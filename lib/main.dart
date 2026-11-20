import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather/view/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    Platform.isIOS
        ? const CupertinoApp(
            debugShowCheckedModeBanner: false,
            home: MainScreen(),
          )
        : const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MainScreen(),
          ),
  );
}
