import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/consumer_digitp_models.dart';
import '../../domain/enquiry.dart';

import '../../providers/consumer_digitp_provider.dart';
import '../enquiry/enquiries_screen.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/digitp_modal.dart';
import '../../l10n/app_localizations.dart';

enum ActivityChip { all, notReceived, live, delivered, enquiries }

class ConsumerActivityScreen extends ConsumerStatefulWidget {
  final ActivityChip initialChip;

  const ConsumerActivityScreen({
    super.key,
    this.initialChip = ActivityChip.live,
  });

  @override
  ConsumerState<ConsumerActivityScreen> createState() => _ConsumerActivityScreenState();
}

class _ConsumerActivityScreenState extends ConsumerState<ConsumerActivityScreen> {
  late ActivityChip _activeChip;

  @override
  void initState() {
    super.initState();
    _activeChip = widget.initialChip;
  }

  void _showDigiTpModal(BuildContext context, ConsumerDigiTpItem item) {
    showDigiTpPassModal(
      context,
      item: item,
    );
  }

  int _getStatusForChip(ActivityChip chip) {
    switch (chip) {
      case ActivityChip.all:
        return 0;
      case ActivityChip.notReceived:
        return 1;
      case ActivityChip.delivered:
        return 3;
      case ActivityChip.live:
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final enquiries = ref.watch(enquiriesProvider);
    final allAsync = ref.watch(consumerDigiTpListProvider(0));
    final notReceivedAsync = ref.watch(consumerDigiTpListProvider(1));
    final inTransitAsync = ref.watch(consumerDigiTpListProvider(2));
    final deliveredAsync = ref.watch(consumerDigiTpListProvider(3));

    final allCount = (allAsync.valueOrNull?.responseData?.count?.totalCount != null && (allAsync.valueOrNull?.responseData?.count?.totalCount ?? 0) > 0) 
        ? allAsync.valueOrNull!.responseData!.count!.totalCount
        : (allAsync.valueOrNull?.items.length ?? 0);

    final inTransitCount = (inTransitAsync.valueOrNull?.responseData?.count?.inTransitCount != null && (inTransitAsync.valueOrNull?.responseData?.count?.inTransitCount ?? 0) > 0)
        ? inTransitAsync.valueOrNull!.responseData!.count!.inTransitCount
        : (inTransitAsync.valueOrNull?.items.length ?? 0);

    final deliveredCount = (deliveredAsync.valueOrNull?.responseData?.count?.deliveredCount != null && (deliveredAsync.valueOrNull?.responseData?.count?.deliveredCount ?? 0) > 0)
        ? deliveredAsync.valueOrNull!.responseData!.count!.deliveredCount
        : (deliveredAsync.valueOrNull?.items.length ?? 0);

    final notReceivedCount = (notReceivedAsync.valueOrNull?.responseData?.count?.notReceivedCount != null && (notReceivedAsync.valueOrNull?.responseData?.count?.notReceivedCount ?? 0) > 0)
        ? notReceivedAsync.valueOrNull!.responseData!.count!.notReceivedCount
        : (notReceivedAsync.valueOrNull?.items.length ?? 0);

    final activeStatus = _getStatusForChip(_activeChip);
    final activeAsync = activeStatus == 0 ? allAsync : (activeStatus == 1 ? notReceivedAsync : (activeStatus == 2 ? inTransitAsync : deliveredAsync));

    return AppScaffold(
      title: loc.digitpDeliveries.replaceAll('\n', ' '),
      showBackButton: Navigator.canPop(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(consumerDigiTpListProvider(0));
          ref.invalidate(consumerDigiTpListProvider(1));
          ref.invalidate(consumerDigiTpListProvider(2));
          ref.invalidate(consumerDigiTpListProvider(3));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip(
                      chip: ActivityChip.all,
                      icon: Icons.list_alt_outlined,
                      label: loc.all,
                      count: allCount,
                      isLoading: allAsync.isLoading,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      chip: ActivityChip.notReceived,
                      icon: Icons.pending_actions_outlined,
                      label: loc.notReceived,
                      count: notReceivedCount,
                      isLoading: notReceivedAsync.isLoading,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      chip: ActivityChip.live,
                      icon: Icons.local_shipping_outlined,
                      label: loc.inTransit,
                      count: inTransitCount,
                      isLoading: inTransitAsync.isLoading,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      chip: ActivityChip.delivered,
                      icon: Icons.check_circle_outline,
                      label: loc.delivered,
                      count: deliveredCount,
                      isLoading: deliveredAsync.isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ENQUIRIES CHIP
              if (_activeChip == ActivityChip.enquiries) ...[
                ...enquiries.map((enq) => _buildEnquiryCard(context, enq)),
              ],

              // DIGITP LIST (ALL status=0 OR NOT RECEIVED status=1 OR IN TRANSIT status=2 OR DELIVERED status=3)
              if (_activeChip == ActivityChip.all || _activeChip == ActivityChip.notReceived || _activeChip == ActivityChip.live || _activeChip == ActivityChip.delivered) ...[
                activeAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 3),
                          SizedBox(height: 12),
                          Text(
                            loc.fetchingConsumerDigiTpRecords,
                            style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 36, color: Color(0xFFDC2626)),
                        const SizedBox(height: 8),
                        Text(
                          loc.failedToLoadDigiTpList,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: loc.retryFetching,
                          size: AppButtonSize.small,
                          variant: AppButtonVariant.primary,
                          onPressed: () => ref.invalidate(consumerDigiTpListProvider(activeStatus)),
                        ),
                      ],
                    ),
                  ),
                  data: (response) {
                    final items = response.items;

                    if (items.isEmpty) {
                      final titleStr = activeStatus == 0 ? loc.noDeliveriesFound : (activeStatus == 1 ? loc.noDeliveriesFound : (activeStatus == 2 ? loc.noActiveDeliveries : loc.noDeliveredItems));
                      final subStr = activeStatus == 0 ? loc.noDeliveriesFoundDesc : (activeStatus == 1 ? loc.noDeliveriesFoundDesc : (activeStatus == 2
                          ? loc.noDeliveriesInTransitDesc
                          : loc.noDeliveriesReceivedDesc));

                      return Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                activeStatus == 2 ? Icons.local_shipping_outlined : Icons.assignment_outlined,
                                size: 36,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              titleStr,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subStr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSecondary),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: loc.refreshLocation,
                              size: AppButtonSize.small,
                              variant: AppButtonVariant.secondary,
                              icon: const Icon(Icons.refresh, size: 16),
                              onPressed: () => ref.invalidate(consumerDigiTpListProvider(activeStatus)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildDigiTpCard(context, item, activeStatus);
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigiTpCard(BuildContext context, ConsumerDigiTpItem item, int activeStatus) {
    final loc = AppLocalizations.of(context)!;
    String statusLabel = item.invoiceStatus ?? (activeStatus == 1 ? loc.notReceived : (activeStatus == 2 ? loc.inTransit : loc.delivered));
    if (statusLabel.toUpperCase() == 'NOT RECEIVED') {
      statusLabel = 'Not Received';
    }
    final isDelivered = activeStatus == 3 || statusLabel.toLowerCase() == 'delivered' || statusLabel == loc.delivered;

    final badgeBg = isDelivered ? const Color(0xFFF0FDF4) : const Color(0xFFF7F0FD);
    final badgeBorder = isDelivered ? const Color(0xFFBBF7D0) : const Color(0xFFEBD9FB);
    final badgeFg = isDelivered ? const Color(0xFF15803D) : const Color(0xFF7E22CE);

    final qtyStr = '${item.quantity ?? 0} ${item.mineralUnit ?? 'Brass'}';
    final mineralStr = item.materialType ?? 'Mineral';
    final vehicleNoStr = item.vehicleNo ?? 'Vehicle N/A';
    final destStr = item.destination ?? 'Destination N/A';
    final driverStr = item.driverName != null && item.driverName!.isNotEmpty
        ? '${item.driverName}${item.driverMobNo != null ? ' (${item.driverMobNo})' : ''}'
        : 'N/A';
    final ownerStr = item.ownerName ?? 'Quarry / Stockyard';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined, size: 15, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DigiTP: ${item.invoiceNo}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(loc.destination, style: const TextStyle(fontSize: 11, color: Color(0xFF737373))),
          Text(destStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${loc.mineral}: $mineralStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                Text('${loc.qty}: $qtyStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${loc.vehicle}:', style: const TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Text(vehicleNoStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${loc.driver}:', style: const TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Text(driverStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${loc.quarrySeller}:', style: const TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Expanded(
                      child: Text(
                        ownerStr,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
                if (item.validityFrom != null || item.validityUpto != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${loc.validity}:', style: const TextStyle(fontSize: 11, color: Color(0xFF737373))),
                      Text(
                        '${AppDateFormatter.formatDateTime(item.validityFrom)} - ${AppDateFormatter.formatDateTime(item.validityUpto)}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ],

              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              if (!isDelivered) ...[
                Expanded(
                  child: AppButton(
                    label: loc.trackVehicle.replaceAll('\n', ' '),
                    size: AppButtonSize.small,
                    icon: const Icon(Icons.navigation_outlined, size: 16),
                    onPressed: () => context.push('/deliveries/${item.invoiceNo}/live-tracking?vehicleNo=${item.vehicleNo ?? item.invoiceNo}'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: AppButton(
                  label: loc.viewDigiTp,
                  size: AppButtonSize.small,
                  variant: AppButtonVariant.secondary,
                  icon: const Icon(Icons.qr_code, size: 16),
                  onPressed: () => _showDigiTpModal(context, item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required ActivityChip chip,
    required IconData icon,
    required String label,
    required int count,
    required bool isLoading,
  }) {
    final isSelected = _activeChip == chip;

    return InkWell(
      onTap: () => setState(() => _activeChip = chip),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF525252)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF404040),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x33FFFFFF) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isSelected ? Colors.white : AppColors.primary700,
                      ),
                    )
                  : Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF404040),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(BuildContext context, Enquiry enq) {
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeFg = const Color(0xFF2563EB);
    if (enq.status == EnquiryStatus.actionRequired) {
      badgeBg = const Color(0xFFFFFBEB);
      badgeFg = const Color(0xFFD97706);
    } else if (enq.status == EnquiryStatus.digitpGenerated) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeFg = const Color(0xFF16A34A);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/enquiries/detail', extra: enq),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(enq.enquiryNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                    child: Text(enq.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeFg)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(enq.mineralName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
              Text('Qty: ${enq.requiredQuantity.formatted} · ${AppLocalizations.of(context)!.source}: ${enq.stockPointName}', style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
