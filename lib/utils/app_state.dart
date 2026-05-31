import 'package:flutter/material.dart';

// A simple global flag so notifications know if the app is open
class AppState with WidgetsBindingObserver {
  static bool isInForeground = false;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isInForeground = state == AppLifecycleState.resumed;
  }
}