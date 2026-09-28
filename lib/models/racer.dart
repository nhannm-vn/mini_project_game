import 'package:flutter/material.dart';

class Racer {
  final int id;
  final String name;
  final Color color;
  final double odds;
  final String assetPath;
  double progress;

  Racer({
    required this.id,
    required this.name,
    required this.color,
    required this.odds,
    required this.assetPath,
    this.progress = 0.0,
  });
}
