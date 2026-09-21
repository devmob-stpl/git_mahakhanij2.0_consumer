import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/mineral.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';
import 'mineral_catalog_screen.dart';

class StockPointMapScreen extends ConsumerStatefulWidget {
  const StockPointMapScreen({super.key});

  @override
  ConsumerState<StockPointMapScreen> createState() => _StockPointMapScreenState();
}

class _StockPointMapScreenState extends ConsumerState<StockPointMapScreen> {
  final _searchController = TextEditingController();
  bool _isMapView = false;
  String _selectedMineral = 'ALL';
  String _maxDistance = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mineralRepo = ref.watch(mineralRepositoryProvider);

    return AppScaffold(
      title: 'Find mineral place',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(_isMapView ? Icons.list_alt : Icons.map_outlined, color: AppColors.ink),
          onPressed: () => setState(() => _isMapView = !_isMapView),
        ),
      ],
      body: FutureBuilder<List<StockPoint>>(
        future: mineralRepo.listStockPoints(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final points = snapshot.data!;
          final filtered = points.where((sp) {
            final query = _searchController.text.trim().toLowerCase();
            return query.isEmpty ||
                sp.name.toLowerCase().contains(query) ||
                sp.address.taluka.toLowerCase().contains(query) ||
                sp.address.district.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              // Search & Filter Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Colors.white,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Mineral place, taluka or district',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.inkMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchController.clear()))
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Filter Quick Pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filtered.length} mineral places',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkSecondary),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _isMapView = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: !_isMapView ? AppColors.primary700 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: !_isMapView ? AppColors.primary700 : AppColors.line),
                                ),
                                child: Text('List', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: !_isMapView ? Colors.white : AppColors.ink)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => setState(() => _isMapView = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isMapView ? AppColors.primary700 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _isMapView ? AppColors.primary700 : AppColors.line),
                                ),
                                child: Text('Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _isMapView ? Colors.white : AppColors.ink)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Body: Either Map or List
              Expanded(
                child: _isMapView
                    ? _buildMapCanvas(filtered)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final sp = filtered[index];

                          return AppCard(
                            onTap: () => context.push('/minerals/stock-points/detail', extra: sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sp.code,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700, fontFamily: 'monospace'),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                                      child: const Text('Approved Quarry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  sp.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Operator: ${sp.operatorName}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        sp.address.formattedAddress,
                                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                                      ),
                                    ),
                                    Text(
                                      '${sp.distanceKm} km away',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary700,
                                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => context.push('/minerals/stock-points/detail', extra: sp),
                                        child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => context.push('/enquiries/create'),
                                        child: const Text('Send enquiry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapCanvas(List<StockPoint> points) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFE2E8F0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                const Text('Stock Points Geographic Map View', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('Displaying ${points.length} government verified quarries on map', style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary700, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Tap any point to inspect mineral stock or raise statutory quotation.', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                ),
                TextButton(
                  onPressed: () => setState(() => _isMapView = false),
                  child: const Text('Switch to List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
