import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/prototype_bar.dart';

class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).currentUser;
    final isOrg = user?.userType == UserType.organization;

    // Organization: Home(0) · Projects(1) · Activity(2) · More(4)
    // Consumer:     Home(0) · Activity(2) · Report(3)   · More(4)
    final tabConfigs = isOrg
        ? [
            const _TabConfig(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home, branchIndex: 0),
            const _TabConfig(label: 'Projects', icon: Icons.layers_outlined, activeIcon: Icons.layers, branchIndex: 1),
            const _TabConfig(label: 'Activity', icon: Icons.show_chart, activeIcon: Icons.show_chart, branchIndex: 2),
            const _TabConfig(label: 'More', icon: Icons.more_horiz, activeIcon: Icons.more_horiz, branchIndex: 4),
          ]
        : [
            const _TabConfig(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home, branchIndex: 0),
            const _TabConfig(label: 'Activity', icon: Icons.show_chart, activeIcon: Icons.show_chart, branchIndex: 2),
            const _TabConfig(label: 'Report', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, branchIndex: 3),
            const _TabConfig(label: 'More', icon: Icons.more_horiz, activeIcon: Icons.more_horiz, branchIndex: 4),
          ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          const PrototypeBar(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFDDE3EE), width: 1)),
        ),
        padding: EdgeInsets.only(
          top: 6,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom
              : 8,
        ),
        child: Row(
          children: List.generate(tabConfigs.length, (index) {
            final tab = tabConfigs[index];
            final isActive = navigationShell.currentIndex == tab.branchIndex;

            return Expanded(
              child: InkWell(
                onTap: () {
                  navigationShell.goBranch(
                    tab.branchIndex,
                    initialLocation: tab.branchIndex == navigationShell.currentIndex,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFEEF4FF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 20,
                        color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int branchIndex;

  const _TabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.branchIndex,
  });
}
