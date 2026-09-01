import 'package:flutter/material.dart';

enum Environment { dg, uat, live }

class AppConfig {
  static const String appName = 'Nakshatra Jewellery';
  static const Environment environment = Environment.live;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  // Design Canvas Dimensions (standard mobile design baseline)
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;
}
