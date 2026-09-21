import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/delivery.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_scaffold.dart';

class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  List<Delivery> _deliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() => _isLoading = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final all = await repo.listDeliveries(activeOnly: false);

    if (mounted) {
      setState(() {
        _deliveries = all.where((d) =>
          d.status == DeliveryStatus.arrivedAtDestination ||
          d.status == DeliveryStatus.inTransit ||
          d.status == DeliveryStatus.dispatched
        ).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arrivedDeliveries = _deliveries.where((d) => d.status == DeliveryStatus.arrivedAtDestination).toList();
    final inTransitDeliveries = _deliveries.where((d) => d.status == DeliveryStatus.inTransit || d.status == DeliveryStatus.dispatched).toList();
    final primaryTargetDelivery = arrivedDeliveries.isNotEmpty ? arrivedDeliveries.first : (inTransitDeliveries.isNotEmpty ? inTransitDeliveries.first : null);

    return AppScaffold(
      title: 'Material Receiving & DigiTP',
      showBackButton: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Quick QR Scan Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6E5F8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.qr_code_scanner, size: 24, color: Color(0xFF1241A6)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scan DigiTP Transit Pass',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Point camera at the driver\'s QR code to verify & receive',
                                    style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Open QR Scanner',
                          fullWidth: true,
                          size: AppButtonSize.large,
                          icon: const Icon(Icons.qr_code, size: 18),
                          onPressed: () {
                            if (primaryTargetDelivery != null) {
                              context.push('/receiving/detail', extra: {'deliveryId': primaryTargetDelivery.id});
                            } else {
                              context.push('/receiving/detail', extra: {'deliveryId': 'del-003'});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Vehicles at Site Gate (Ready to Receive)
                  if (arrivedDeliveries.isNotEmpty) ...[
                    const Text(
                      'VEHICLES AT SITE GATE (READY TO RECEIVE)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF737373), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'The following vehicles have reached your site geofence and are waiting to be unloaded.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(height: 10),

                    ...arrivedDeliveries.map((delivery) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
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
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.check_circle, size: 16, color: Color(0xFF15803D)),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            delivery.vehicle.registrationNumber,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'monospace'),
                                          ),
                                          const Text(
                                            'At Site Gate · Ready to Offload',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('Arrived', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFDCFCE7)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Mineral: Basalt Stone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                    Text(
                                      'Dispatched: ${delivery.transportPermit.permittedQuantity.formatted}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Verify & Receive Material',
                                fullWidth: true,
                                size: AppButtonSize.medium,
                                icon: const Icon(Icons.qr_code, size: 16),
                                onPressed: () => context.push('/receiving/detail', extra: {'deliveryId': delivery.id}),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // 3. Vehicles In Transit (En Route)
                  if (inTransitDeliveries.isNotEmpty) ...[
                    const Text(
                      'VEHICLES IN TRANSIT (EN ROUTE)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF737373), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Trucks currently moving toward your site location.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(height: 10),

                    ...inTransitDeliveries.map((delivery) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
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
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF4FE),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF1241A6)),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            delivery.vehicle.registrationNumber,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'monospace'),
                                          ),
                                          Text(
                                            'DigiTP: ${delivery.transportPermit.etpNumber}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF737373)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F0FD),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('In Transit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7E22CE))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Natural River Sand', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                    Text(
                                      delivery.transportPermit.permittedQuantity.formatted,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Distance & Driver Details Box
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.navigation_outlined, size: 13, color: Color(0xFF1241A6)),
                                            SizedBox(width: 4),
                                            Text('Distance & ETA:', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                                          ],
                                        ),
                                        Text('~4.2 km away (15 mins)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                                            SizedBox(width: 4),
                                            Text('Destination:', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                                          ],
                                        ),
                                        Expanded(
                                          child: Text(
                                            delivery.transportPermit.destinationLabel,
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.phone_outlined, size: 13, color: Color(0xFF64748B)),
                                            SizedBox(width: 4),
                                            Text('Driver:', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                                          ],
                                        ),
                                        Text(
                                          '${delivery.vehicle.driverName} (${delivery.vehicle.driverMobileNumber})',
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Geofence Lock Notice
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.lock_outline, size: 16, color: Color(0xFFD97706)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Receiving locked in transit. Unlocks automatically once vehicle enters within 200m of site geofence.',
                                        style: TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.25),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      label: 'Track Vehicle',
                                      size: AppButtonSize.small,
                                      variant: AppButtonVariant.secondary,
                                      icon: const Icon(Icons.navigation_outlined, size: 16),
                                      onPressed: () => context.push('/deliveries/${delivery.id}/live-tracking'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppButton(
                                      label: 'Scan & Receive',
                                      size: AppButtonSize.small,
                                      icon: const Icon(Icons.qr_code, size: 16),
                                      onPressed: () => context.push('/receiving/detail', extra: {'deliveryId': delivery.id}),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],

                  // 4. Empty State
                  if (_deliveries.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No Active Mineral Deliveries',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'There are currently no vehicles in transit or waiting at your sites.',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
