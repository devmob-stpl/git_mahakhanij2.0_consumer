import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/consumer_digitp_repository.dart';
import '../domain/consumer_digitp_models.dart';
import 'session_provider.dart';
import 'consumer_profile_provider.dart';

final consumerDigiTpRepositoryProvider = Provider<ConsumerDigiTpRepository>((ref) {
  return ConsumerDigiTpRepositoryImpl();
});

/// Fetches DigiTP list for logged-in user using dynamic consumerId from Login API or Profile API.
/// [status]: 1 = In Transit, 2 = Delivered.
final consumerDigiTpListProvider = FutureProvider.family<ConsumerDigiTpApiResponse, int>((ref, status) async {
  final repo = ref.watch(consumerDigiTpRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final user = session.currentUser;

  int? resolvedConsumerId = user?.consumerId;

  // If consumerId not present in User object, attempt resolving from Profile API response
  if (resolvedConsumerId == null || resolvedConsumerId <= 0) {
    final mob = user?.mobileNumber ?? '';
    if (mob.isNotEmpty) {
      final profileAsync = ref.watch(consumerProfileProvider(mob));
      final profile = profileAsync.valueOrNull?.responseData;
      if (profile != null && profile.id > 0) {
        resolvedConsumerId = profile.id;
      }
    }
  }

  // Fallback to numeric user id if available
  if (resolvedConsumerId == null || resolvedConsumerId <= 0) {
    if (user?.id != null && int.tryParse(user!.id) != null && int.parse(user.id) > 0) {
      resolvedConsumerId = int.parse(user.id);
    }
  }

  final consumerId = (resolvedConsumerId != null && resolvedConsumerId > 0) ? resolvedConsumerId : 412;

  return repo.getConsumerDigiTpList(consumerId: consumerId, status: status);
});
