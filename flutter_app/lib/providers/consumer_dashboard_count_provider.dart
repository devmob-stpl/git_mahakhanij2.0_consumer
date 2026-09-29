import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/consumer_dashboard_count_repository.dart';
import '../domain/consumer_dashboard_count_models.dart';
import 'session_provider.dart';
import 'consumer_profile_provider.dart';

final consumerDashboardCountRepositoryProvider = Provider<ConsumerDashboardCountRepository>((ref) {
  return ConsumerDashboardCountRepositoryImpl();
});

/// Fetches dashboard summary counts for logged-in user dynamically.
final consumerDashboardCountProvider = FutureProvider<ConsumerDashboardCountApiResponse>((ref) async {
  final repo = ref.watch(consumerDashboardCountRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final user = session.currentUser;

  int? resolvedConsumerId = user?.consumerId;

  // Resolve consumerId dynamically from Session or Profile API
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

  return repo.getConsumerDashboardCount(consumerId);
});
