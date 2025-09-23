import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/naver_map/geocoding_model.dart';
import '../repositories/geocoding_repository.dart';

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepository();
});

final reverseGeocodedAddressProvider =
    FutureProvider.family<String, Coordinates>((ref, coords) async {
  final repository = ref.watch(geocodingRepositoryProvider);
  return repository.getAddressFromCoordinates(
    latitude: coords.latitude,
    longitude: coords.longitude,
  );
});
