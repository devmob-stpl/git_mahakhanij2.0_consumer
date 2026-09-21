import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/package.dart';
import '../../providers/operating_context_provider.dart';
import '../../shared/widgets/app_scaffold.dart';

class RegisterSupervisorScreen extends ConsumerStatefulWidget {
  const RegisterSupervisorScreen({super.key});

  @override
  ConsumerState<RegisterSupervisorScreen> createState() => _RegisterSupervisorScreenState();
}

class _RegisterSupervisorScreenState extends ConsumerState<RegisterSupervisorScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String? _selectedPackage;

  final List<String> _packageOptions = [
    'Package A — Km 12 to Km 28',
    'Package B — Km 28 to Km 41',
    'Package C — Km 42 to Km 65',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter supervisor name')),
      );
      return;
    }
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter supervisor contact detail')),
      );
      return;
    }

    final newSup = SupervisorInfo(
      id: 'sup-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      mobileNumber: contact,
      employeeCode: 'SUP-${(1000 + DateTime.now().millisecond).toString()}',
      assignedPackageName: _selectedPackage ?? 'Package A — Km 12 to Km 28',
    );

    await ref.read(organizationRepositoryProvider).registerSupervisor(newSup);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supervisor registered successfully!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register supervisor',
      showBackButton: true,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner Block
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF1D4ED8),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TEAM MANAGEMENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Register supervisor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add a site supervisor to authorize on-site deliveries, verify arriving vehicles, and oversee material receiving.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // 2. Form Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field 1: Supervisor name *
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      children: [
                        TextSpan(text: 'Supervisor name '),
                        TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Anand R. Patil',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Field 2: Supervisor contact detail *
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      children: [
                        TextSpan(text: 'Supervisor contact detail '),
                        TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF94A3B8)),
                      hintText: '98XXXXXXXX',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '10-digit mobile number for SMS and delivery alerts',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 18),

                  // Field 3: Assigned to package (optional)
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, size: 16, color: Color(0xFF1D4ED8)),
                      const SizedBox(width: 6),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          children: [
                            TextSpan(text: 'Assigned to package '),
                            TextSpan(text: '(optional)', style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPackage,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items: _packageOptions.map((pkg) {
                      return DropdownMenuItem(value: pkg, child: Text(pkg, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPackage = val),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can assign this supervisor to an active package now or link them later during package creation.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.35),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 20),

                  // 3. Register Supervisor Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _onRegister,
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text(
                        'Register supervisor',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 8,
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, () => context.go('/home')),
          _buildNavItem(Icons.layers_outlined, 'Projects', true, () => context.go('/organization/projects')),
          _buildNavItem(Icons.show_chart, 'Activity', false, () => context.go('/activity')),
          _buildNavItem(Icons.more_horiz, 'More', false, () => context.go('/more')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
                icon,
                size: 20,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
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
  }
}
