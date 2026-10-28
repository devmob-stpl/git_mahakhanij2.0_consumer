import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    if (user == null || user.isConsumer) {
      return const ConsumerDashboard();
    }

    if (user.isOrganization) {
      return const OrganizationDashboard();
    }

    if (user.isSupervisor) {
      return const SupervisorDashboard();
    }

    return const ConsumerDashboard();
  }
}
