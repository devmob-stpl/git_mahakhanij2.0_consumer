import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/vehicle_tracking_models.dart';
import '../../providers/vehicle_tracking_provider.dart';


class LiveVehicleTrackingScreen extends ConsumerStatefulWidget {
  final String deliveryId;
  final String? vehicleNo;

  const LiveVehicleTrackingScreen({
    super.key,
    required this.deliveryId,
    this.vehicleNo,
  });

  @override
  ConsumerState<LiveVehicleTrackingScreen> createState() => _LiveVehicleTrackingScreenState();
}

class _LiveVehicleTrackingScreenState extends ConsumerState<LiveVehicleTrackingScreen> {
  late TextEditingController _vehicleSearchController;
  late String _activeVehicleNo;
  final double _sheetSize = 0.50; // Initial sheet size


  @override
  void initState() {
    super.initState();
    // Resolve initial vehicle number
    _activeVehicleNo = _resolveVehicleNo(widget.vehicleNo, widget.deliveryId);
    _vehicleSearchController = TextEditingController(text: _activeVehicleNo);
  }

  @override
  void dispose() {
    _vehicleSearchController.dispose();
    super.dispose();
  }

  String _resolveVehicleNo(String? passedVehicleNo, String deliveryId) {
    if (passedVehicleNo != null && passedVehicleNo.trim().isNotEmpty) {
      return passedVehicleNo.trim();
    }
    final cleanedId = deliveryId.trim();
    // Check if deliveryId looks like an Indian vehicle registration number (e.g. MH40CT2800)
    final vehicleRegRegex = RegExp(r'^[A-Za-z]{2}\d{1,2}[A-Za-z]{1,3}\d{1,4}$');
    if (vehicleRegRegex.hasMatch(cleanedId.replaceAll('-', '').replaceAll(' ', ''))) {
      return cleanedId;
    }
    // Default fallback vehicle number provided in API specification
    return 'MH40CT2800';
  }

  void _triggerSearch() {
    final query = _vehicleSearchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _activeVehicleNo = query;
      });
      ref.invalidate(vehicleTrackingProvider(_activeVehicleNo));
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot make call to $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingAsync = ref.watch(vehicleTrackingProvider(_activeVehicleNo));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Vehicle Tracking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            Text(
              'Vehicle: $_activeVehicleNo · Live GPS',
              style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary700),
            tooltip: 'Refresh Telemetry',
            onPressed: () {
              ref.invalidate(vehicleTrackingProvider(_activeVehicleNo));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: TextField(
                      controller: _vehicleSearchController,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                      decoration: const InputDecoration(
                        hintText: 'Enter Vehicle No (e.g. MH40CT2800)',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                        prefixIcon: Icon(Icons.directions_car, size: 18, color: AppColors.inkSecondary),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _triggerSearch(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _triggerSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Track', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: trackingAsync.when(
        loading: () => _buildLoadingState(),
        error: (err, stack) => _buildErrorState(err.toString()),
        data: (apiResponse) {
          // Check for API errors or empty responseData
          if (!apiResponse.isSuccess && apiResponse.statusCode != '200') {
            return _buildErrorState(apiResponse.statusMessage);
          }

          if (!apiResponse.hasLocation) {
            return _buildEmptyLocationState(apiResponse.statusMessage);
          }

          final location = apiResponse.location!;
          final trip = apiResponse.trip;

          return Stack(
            children: [
              // 1. Dynamic Interactive Vehicle Map Canvas
              Positioned.fill(
                child: _buildMapCanvas(location, trip),
              ),

              // 2. Draggable Dynamic Telemetry & Trip Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: _sheetSize,
                minChildSize: 0.18,
                maxChildSize: 0.68,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      children: [
                        // Drag Pill Handle
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Section 1: Header Vehicle Overview
                        _buildVehicleHeaderCard(location),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.line),
                        const SizedBox(height: 14),

                        // Section 2: Current Location & Status Banner
                        _buildLocationBannerCard(location),
                        const SizedBox(height: 14),

                        // Section 3: Trip Details (if responseData1 available)
                        if (trip != null) ...[
                          _buildTripDetailsCard(trip),
                          const SizedBox(height: 14),
                        ] else ...[
                          _buildNoTripCard(),
                          const SizedBox(height: 14),
                        ],



                        // Section 5: Driver Contact & Action Buttons
                        _buildDriverActionCard(location, trip),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENTS & MAP CANVAS
  // ===========================================================================

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary700),
            const SizedBox(height: 16),
            Text(
              'Fetching live GPS location for $_activeVehicleNo...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connecting to Mahakhanij GPS Tracking Service',
              style: TextStyle(fontSize: 11, color: AppColors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            const Text(
              'Tracking Data Unavailable',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(vehicleTrackingProvider(_activeVehicleNo));
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry Fetching'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary700,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _activeVehicleNo = 'MH40CT2800';
                      _vehicleSearchController.text = 'MH40CT2800';
                    });
                    ref.invalidate(vehicleTrackingProvider('MH40CT2800'));
                  },
                  child: const Text('Try Demo Vehicle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLocationState(String statusMsg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined, size: 40, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            Text(
              'No Location Data for $_activeVehicleNo',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              statusMsg.isNotEmpty
                  ? statusMsg
                  : 'The GPS device for this vehicle is currently offline or has no reported coordinates.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(vehicleTrackingProvider(_activeVehicleNo)),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCanvas(VehicleLocationData location, VehicleTripData? trip) {
    final statusColorHex = location.colorCode ?? '#15803D';
    Color vehicleColor;
    try {
      vehicleColor = Color(int.parse(statusColorHex.replaceAll('#', '0xFF')));
    } catch (_) {
      vehicleColor = const Color(0xFF15803D);
    }

    final speedText = location.speed != null ? '${location.speed} km/h' : '0 km/h';
    final locationStr = location.locationName ?? 'Coordinates: ${location.latitude ?? '-'}, ${location.longitude ?? '-'}';

    return Container(
      color: const Color(0xFFE2E8F0),
      child: Stack(
        children: [
          // Background Vector Custom Grid
          CustomPaint(
            size: Size.infinite,
            painter: _DynamicMapCanvasPainter(),
          ),

          // Map Control Info Pills (Top Right)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(242),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        location.gpsStatus?.toLowerCase() == 'active' ? Icons.gps_fixed : Icons.gps_not_fixed,
                        size: 14,
                        color: location.gpsStatus?.toLowerCase() == 'active' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'GPS: ${location.gpsStatus ?? 'N/A'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // Vehicle Center Live Marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing Marker Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: vehicleColor.withAlpha(51),
                      ),
                    ),

                    Transform.rotate(
                      angle: ((location.direction ?? 0) * 3.14159 / 180),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: vehicleColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.navigation, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Vehicle No & Speed Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${location.vehicleNo ?? _activeVehicleNo} ($speedText)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                      Text(
                        locationStr,
                        style: const TextStyle(fontSize: 10, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeaderCard(VehicleLocationData location) {
    final statusText = location.vehicleStatus ?? 'Active';
    final isRunning = statusText.toLowerCase() == 'running';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    location.vehicleNo ?? _activeVehicleNo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: isRunning ? const Color(0xFF15803D) : const Color(0xFFE11D48),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${location.vehTypeName ?? 'Commercial Vehicle'} · Capacity: ${location.capacity ?? 'N/A'} Tons',
                style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isRunning ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isRunning ? const Color(0xFF86EFAC) : const Color(0xFFFECDD3)),
          ),
          child: Text(
            statusText.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isRunning ? const Color(0xFF15803D) : const Color(0xFFBE123C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBannerCard(VehicleLocationData location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E5F8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 22),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT GPS LOCATION',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF134280), letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  location.locationName ?? 'Location details unavailable',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  'Speed: ${location.speed ?? 0} km/h · Last updated: ${AppDateFormatter.formatDateTime(location.deviceDatetime)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(VehicleTripData trip) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.route, size: 18, color: AppColors.primary700),
                  SizedBox(width: 6),
                  Text(
                    'Trip Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Trip ID: ${trip.tripID ?? 'N/A'}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Origin / Destination timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Icon(Icons.radio_button_checked, size: 16, color: AppColors.primary700),
                  SizedBox(
                    height: 32,
                    child: VerticalDivider(thickness: 1.5, color: AppColors.line),
                  ),
                  Icon(Icons.location_on, size: 16, color: Color(0xFFEF4444)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Origin / Quarry Plot', style: TextStyle(fontSize: 10.5, color: AppColors.inkMuted)),
                    Text(
                      '${trip.plotName ?? 'N/A'} (${trip.taluka ?? ''}, ${trip.district ?? ''})',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 16),
                    const Text('Destination Site', style: TextStyle(fontSize: 10.5, color: AppColors.inkMuted)),
                    Text(
                      trip.destination ?? 'Destination unspecified',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Trip metadata chips
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Division', trip.division ?? 'N/A'),
                _buildInfoColumn('District', trip.district ?? 'N/A'),
                _buildInfoColumn('Taluka', trip.taluka ?? 'N/A'),
                _buildInfoColumn('Distance', trip.distance != null ? '${trip.distance} km' : 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Valid From: ${AppDateFormatter.formatDateTime(trip.validityFrom)}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.inkSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Valid Upto: ${AppDateFormatter.formatDateTime(trip.validityUpto)}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.primary700),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildNoTripCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.inkSecondary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No active DigiTP trip details associated with this vehicle at the moment.',
              style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDriverActionCard(VehicleLocationData location, VehicleTripData? trip) {
    final driverName = location.driverName ?? trip?.driverName ?? 'Driver N/A';
    final driverMobile = location.driverMobileNo ?? trip?.driverMobNo ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFEEF4FE),
                child: Icon(Icons.person, color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  Text(
                    driverMobile.isNotEmpty ? driverMobile : 'Mobile number unavailable',
                    style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                  ),
                ],
              ),
            ],
          ),
          if (driverMobile.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone_in_talk, color: Color(0xFF2563EB), size: 24),
              onPressed: () => _makePhoneCall(driverMobile),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ],
    );
  }
}

class _DynamicMapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.35,
        size.width * 0.25,
        size.height * 0.65,
        size.width * 0.9,
        size.height * 0.8,
      );

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
