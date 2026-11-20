import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/view/widgets/offline_overlay.dart';

class MainScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Net connection checker
  final bool _isConnected = false;
  final bool _toAvoidBottomInset = false;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            resizeToAvoidBottomInset: _toAvoidBottomInset,
            child: Stack(children: [OfflineOverlay(isOffline: _isConnected)]),
          )
        : Scaffold(
            resizeToAvoidBottomInset: _toAvoidBottomInset,
            body: Stack(children: [OfflineOverlay(isOffline: _isConnected)]),
          );
  }
}
