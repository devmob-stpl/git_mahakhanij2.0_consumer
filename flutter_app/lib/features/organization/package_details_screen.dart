import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/package.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';

class PackageDetailsScreen extends ConsumerStatefulWidget {
  final Package package;

  const PackageDetailsScreen({super.key, required this.package});

  @override
  ConsumerState<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends ConsumerState<PackageDetailsScreen> {
  int _selectedTab = 0; // 0 = Stock & Overview, 1 = Delivered Passes (e-TP)
  String _inventoryView = 'chart'; // 'chart' | 'list'
  String _mineralFilter = 'ALL';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _stockBalances = [
    {
      'id': 'min-sand',
      'name': 'River Sand',
      'category': 'Sand',
      'available': 7.0,
      'unit': 'Brass',
      'color': Color(0xFFD97706),
      'bgColor': Color(0xFFFEF3C7),
      'textColor': Color(0xFFB45309),
    },
    {
      'id': 'min-grit',
      'name': 'Grit / Coarse Aggregate (20mm)',
      'category': 'Aggregate',
      'available': 5.0,
      'unit': 'Brass',
      'color': Color(0xFF1A5FE8),
      'bgColor': Color(0xFFEEF4FE),
      'textColor': Color(0xFF1550CC),
    },
    {
      'id': 'min-murum',
      'name': 'Murum / Soil',
      'category': 'Murum',
      'available': 4.0,
      'unit': 'Brass',
      'color': Color(0xFF7C3AED),
      'bgColor': Color(0xFFF3E8FF),
      'textColor': Color(0xFF6D28D9),
    },
  ];

  final List<Map<String, String>> _digiTpList = [
    {
      'id': 'dtp-1',
      'passNumber': 'DTP-2026-6104',
      'vehicleNumber': 'MH-12-PQ-3301',
      'driverName': 'Anil Deshmukh',
      'driverPhone': '+91 98222 98765',
      'mineralName': 'Murum / Soil',
      'quantity': '4.00 Brass',
      'source': 'Talegaon Excavation Depot',
      'deliveredAt': '08:30 AM, Today',
    },
    {
      'id': 'dtp-2',
      'passNumber': 'DTP-2026-5590',
      'vehicleNumber': 'MH-14-EM-8820',
      'driverName': 'Santosh Gaikwad',
      'driverPhone': '+91 98223 11223',
      'mineralName': 'River Sand',
      'quantity': '3.50 Brass',
      'source': 'Mula Pravara Stockyard, Rahuri',
      'deliveredAt': 'Yesterday 05:45 PM',
    },
    {
      'id': 'dtp-3',
      'passNumber': 'DTP-2026-4421',
      'vehicleNumber': 'MH-12-AB-1102',
      'driverName': 'Vinod Kadam',
      'driverPhone': '+91 98224 55443',
      'mineralName': 'Grit / Coarse Aggregate (20mm)',
      'quantity': '5.00 Brass',
      'source': 'Chakan Stone Quarry #4',
      'deliveredAt': '2 days ago',
    },
    {
      'id': 'dtp-4',
      'passNumber': 'DTP-2026-3810',
      'vehicleNumber': 'MH-14-GH-7789',
      'driverName': 'Sachin More',
      'driverPhone': '+91 98225 66778',
      'mineralName': 'River Sand',
      'quantity': '3.50 Brass',
      'source': 'Mula Pravara Stockyard, Rahuri',
      'deliveredAt': '3 days ago',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPassModal(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Electronic Transit Pass (e-TP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: QrImageView(
                  data: 'MH-ETP|${item['passNumber']}|${item['vehicleNumber']}|${item['quantity']}',
                  size: 150,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    _modalRow('DigiTP Number', item['passNumber']!),
                    const SizedBox(height: 6),
                    _modalRow('Vehicle Reg', item['vehicleNumber']!),
                    const SizedBox(height: 6),
                    _modalRow('Mineral', item['mineralName']!),
                    const SizedBox(height: 6),
                    _modalRow('Quantity', item['quantity']!),
                    const SizedBox(height: 6),
                    _modalRow('Driver', '${item['driverName']} (${item['driverPhone']})'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Close', fullWidth: true, onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;

    return AppScaffold(
      title: pkg.name,
      subtitle: pkg.code,
      showBackButton: true,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Actions', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showSpeedDialMenu(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Context Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(pkg.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary700)),
                      AppBadge(label: pkg.status, variant: AppBadgeVariant.success),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(pkg.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pkg.siteAddress.formattedAddress,
                          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar Switcher (Stock & Overview vs Delivered Passes)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 0 ? AppColors.primary700 : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Stock & Overview',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedTab == 0 ? AppColors.primary700 : AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 1 ? AppColors.primary700 : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Delivered Passes (e-TP)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedTab == 1 ? AppColors.primary700 : AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: _selectedTab == 0 ? _buildOverviewTab(context) : _buildDigiTpTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final pkg = widget.package;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Incoming Active Delivery Alert Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_shipping, size: 18, color: Color(0xFF15803D)),
                      SizedBox(width: 8),
                      Text('Vehicle in Transit to this Site', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                    child: const Text('In Transit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('MH-04-HY-1122 • Basalt Stone (10 Brass)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Track live',
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.navigation_outlined, size: 14),
                      onPressed: () => context.push('/deliveries/del-001/live-tracking'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      label: 'Receive',
                      size: AppButtonSize.small,
                      icon: const Icon(Icons.qr_code, size: 14),
                      onPressed: () => context.push('/receive'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Assigned Supervisor Card
        if (pkg.supervisor != null) ...[
          const Text('ASSIGNED FIELD SUPERVISOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF737373), letterSpacing: 0.5)),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFEEF4FE), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.engineering_outlined, color: Color(0xFF1241A6), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pkg.supervisor!.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                          Text('Code: ${pkg.supervisor!.employeeCode} • +91 98220 12345', style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1241A6),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.phone_outlined, size: 14),
                        label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling supervisor...')));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF15803D),
                          side: const BorderSide(color: Color(0xFFBBF7D0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.chat_outlined, size: 14),
                        label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening WhatsApp...')));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // 3. Verified Delivered Mineral Stock on Site
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('DELIVERED STOCK ON SITE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF737373), letterSpacing: 0.5)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.pie_chart_outline, size: 18, color: _inventoryView == 'chart' ? AppColors.primary700 : AppColors.inkMuted),
                  onPressed: () => setState(() => _inventoryView = 'chart'),
                ),
                IconButton(
                  icon: Icon(Icons.list_alt, size: 18, color: _inventoryView == 'list' ? AppColors.primary700 : AppColors.inkMuted),
                  onPressed: () => setState(() => _inventoryView = 'list'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),

        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Verified Available', style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
                  Text('16.00 Brass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 14),

              // Stock Items Progress Bars
              ..._stockBalances.map((item) {
                final double percent = (item['available'] as double) / 16.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(item['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${(item['available'] as double).toStringAsFixed(1)} ${item['unit']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => context.push('/transfers'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('Transfer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary700)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 4. Scoped Operations Links
        const Text('PACKAGE MINERAL OPERATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF737373), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppCard(
                onTap: () => context.push('/inventory'),
                padding: const EdgeInsets.all(12),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warehouse_outlined, color: AppColors.primary700, size: 22),
                    SizedBox(height: 8),
                    Text('Site Inventory', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    Text('Balance & Ledger', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppCard(
                onTap: () => context.push('/orders'),
                padding: const EdgeInsets.all(12),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.primary700, size: 22),
                    SizedBox(height: 8),
                    Text('Active Orders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    Text('Delivery passes', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDigiTpTab() {
    final filtered = _digiTpList.where((item) {
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          item['passNumber']!.toLowerCase().contains(query) ||
          item['vehicleNumber']!.toLowerCase().contains(query);
      final matchesFilter = _mineralFilter == 'ALL' || item['mineralName']!.contains(_mineralFilter);
      return matchesQuery && matchesFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Box
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search DigiTP or Vehicle number...',
            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.inkMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
          ),
        ),
        const SizedBox(height: 12),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('ALL', 'All Minerals'),
              const SizedBox(width: 8),
              _filterChip('Sand', 'River Sand'),
              const SizedBox(width: 8),
              _filterChip('Aggregate', 'Aggregate (20mm)'),
              const SizedBox(width: 8),
              _filterChip('Murum', 'Murum / Soil'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List of Delivered DigiTP Passes
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = filtered[index];

            return AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['passNumber']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary700, fontFamily: 'monospace')),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Delivered', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${item['mineralName']} • ${item['quantity']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text('Vehicle: ${item['vehicleNumber']} • Source: ${item['source']}', style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['deliveredAt']!, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary700,
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.qr_code, size: 14),
                        label: const Text('View DigiTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () => _showPassModal(item),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _filterChip(String key, String label) {
    final active = _mineralFilter == key;

    return InkWell(
      onTap: () => setState(() => _mineralFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary700 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary700 : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? Colors.white : AppColors.ink),
        ),
      ),
    );
  }

  void _showSpeedDialMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Package Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.search, color: AppColors.primary700),
              title: const Text('Find Mineral Places', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Discover nearby quarries for this package'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/minerals/stock-points');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppColors.primary700),
              title: const Text('Receive Mineral', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Scan QR code of truck at site gate'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/receive');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_calls_outlined, color: AppColors.primary700),
              title: const Text('Transfer Stock', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Issue Transfer e-TP to move mineral surplus'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/transfers');
              },
            ),
          ],
        ),
      ),
    );
  }
}
