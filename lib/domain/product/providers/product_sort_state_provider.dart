import 'package:flutter_riverpod/flutter_riverpod.dart';

final sortOptionProvider = StateProvider<String>((ref) => 'latest');
final minPriceProvider = StateProvider<int?>((ref) => null);
final maxPriceProvider = StateProvider<int?>((ref) => null);
final searchKeyWordsProvider = StateProvider<String?>((ref) => null);
