import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/consumer_profile_repository.dart';
import '../domain/consumer_profile_models.dart';

final consumerProfileRepositoryProvider = Provider<ConsumerProfileRepository>((ref) {
  return ConsumerProfileRepositoryImpl();
});

final consumerProfileProvider = FutureProvider.family<ConsumerProfileApiResponse, String>((ref, mobileNo) async {
  final repo = ref.watch(consumerProfileRepositoryProvider);
  return repo.getConsumerProfile(mobileNo);
});
