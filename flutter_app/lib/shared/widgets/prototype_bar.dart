import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../data/mock_db.dart';
import '../../providers/session_provider.dart';

class PrototypeBar extends ConsumerWidget {
  const PrototypeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).currentUser;
    final activeLabel = user != null
        ? (user.userType == UserType.organization ? 'Organization' : 'Individual')
        : 'Signed out';

    return Container(
      color: const Color(0xFF171717), // neutral-900
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 12,
        right: 12,
        bottom: 6,
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 14, color: Color(0xFFA3A3A3)),
          const SizedBox(width: 6),
          const Text(
            'PROTOTYPE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activeLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFD4D4D4),
              ),
            ),
          ),
          InkWell(
            onTap: () => _showPersonaSheet(context, ref),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Switch Persona',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonaSheet(BuildContext context, WidgetRef ref) {
    final db = MockDb();
    final orgUser = db.users.firstWhere((u) => u.userType == UserType.organization);
    final conUser = db.users.firstWhere((u) => u.userType == UserType.normalConsumer);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Choose Persona',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Test the two distinct user experiences built from the same design system.',
                    style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.line),
                ListTile(
                  title: const Text('Organization', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Sanghavi Infrastructure — 3 projects, 5 packages, active deliveries.', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    ref.read(sessionProvider.notifier).switchPersona(orgUser);
                    Navigator.pop(sheetContext);
                    context.go('/home');
                  },
                ),
                const Divider(height: 1, color: AppColors.line),
                ListTile(
                  title: const Text('Individual', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Aniket Deshmukh, Nashik — individual citizen buyer, no organization.', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    ref.read(sessionProvider.notifier).switchPersona(conUser);
                    Navigator.pop(sheetContext);
                    context.go('/home');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
