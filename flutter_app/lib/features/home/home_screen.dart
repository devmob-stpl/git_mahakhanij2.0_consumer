import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../domain/user.dart';
import '../../providers/session_provider.dart';
import 'widgets/organization_dashboard.dart';
import 'widgets/consumer_dashboard.dart';
import 'widgets/supervisor_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final user = sessionState.currentUser;

    if (!AppConfig.enableOrganizationFlow || user == null) {
      return const ConsumerDashboard();
    }

    switch (user.userType) {
      case UserType.organization:
        return const OrganizationDashboard();
      case UserType.normalConsumer:
        return const ConsumerDashboard();
      case UserType.supervisor:
        return const SupervisorDashboard();
    }
  }
}
