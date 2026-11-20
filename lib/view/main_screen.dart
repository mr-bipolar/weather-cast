import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:weather/view/widgets/offline_overlay.dart';

class MainScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Net connection checker
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;

  // helpers
  final bool _toAvoidBottomInset = false;

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

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
