import 'package:flutter/foundation.dart';

@immutable
class Coordinates {
  final double latitude;
  final double longitude;

  const Coordinates({required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
