import 'dart:math';

import 'package:flutter/material.dart';

class Expo10 extends Curve{
  const Expo10();

  @override
  double transformInternal(double t) {
    return pow(1, 2 * (t - 1)).toDouble();
  }
}