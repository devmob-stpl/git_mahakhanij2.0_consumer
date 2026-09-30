import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../l10n/app_localizations.dart';
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
  GoogleMapController? _mapController;
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    // Resolve initial vehicle number
    _activeVehicleNo = _resolveVehicleNo(widget.vehicleNo, widget.deliveryId);
    _vehicleSearchController = TextEditingController(text: _activeVehicleNo);
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    _customMarkerIcon = await _createVehicleMarkerBitmap();
    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _createVehicleMarkerBitmap() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(110, 110);

    // Draw outer pulsing circle (simulated alpha)
    final outerPaint = Paint()..color = const Color(0xFF2563EB).withAlpha(51);
    canvas.drawCircle(const Offset(55, 55), 55, outerPaint);

    // Draw inner blue circle
    final innerPaint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(const Offset(55, 55), 40, innerPaint);
    
    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(const Offset(55, 55), 40, borderPaint);

    // Draw truck icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.local_shipping.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: Icons.local_shipping.fontFamily,
        package: Icons.local_shipping.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
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
      ref.invalidate(vehicleTrackingProvider(VehicleTrackingParams(vehicleNo: _activeVehicleNo, deliveryId: widget.deliveryId)));
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
    final params = VehicleTrackingParams(vehicleNo: _activeVehicleNo, deliveryId: widget.deliveryId);
    
    ref.listen<AsyncValue<VehicleTrackingApiResponse>>(
      vehicleTrackingProvider(params),
      (previous, next) {
        next.whenData((data) {
          if (data.isSuccess && data.location != null) {
            final loc = data.location!;
            final lat = double.tryParse(loc.latitude?.toString() ?? '') ?? 0.0;
            final lng = double.tryParse(loc.longitude?.toString() ?? '') ?? 0.0;
            if (lat != 0.0 && lng != 0.0) {
              _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
            }
          }
        });
      },
    );

    final trackingAsync = ref.watch(vehicleTrackingProvider(params));

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
            Text(
              AppLocalizations.of(context)!.liveVehicleTracking,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            Text(
              '${AppLocalizations.of(context)!.vehicle}: $_activeVehicleNo · ${AppLocalizations.of(context)!.liveGps}',
              style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary700),
            tooltip: 'Refresh Telemetry',
            onPressed: () {
              ref.invalidate(vehicleTrackingProvider(VehicleTrackingParams(vehicleNo: _activeVehicleNo, deliveryId: widget.deliveryId)));
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
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterVehicleNo,
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
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
                    child: Text(AppLocalizations.of(context)!.track, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                        _buildVehicleHeaderCard(location, trip, context),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.line),
                        const SizedBox(height: 14),

                        // Section 2: Current Location & Status Banner
                        _buildLocationBannerCard(location, context),
                        const SizedBox(height: 14),

                        // Section 3: Trip Details (if responseData1 available)
                        if (trip != null) ...[
                          _buildTripDetailsCard(trip, context),
                          const SizedBox(height: 14),
                        ] else ...[
                          _buildNoTripCard(context),
                          const SizedBox(height: 14),
                        ],



                        // Section 5: Driver Contact & Action Buttons
                        _buildDriverActionCard(location, trip, context),
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.fetchingLiveGpsLocation(_activeVehicleNo),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.connectingToMahakhanij,
              style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.trackingDataUnavailable,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(vehicleTrackingProvider(VehicleTrackingParams(vehicleNo: _activeVehicleNo, deliveryId: widget.deliveryId)));
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.retryFetching),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLocationState(String statusMsg) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.noLocationDataFor(_activeVehicleNo),
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
              onPressed: () => ref.invalidate(vehicleTrackingProvider(VehicleTrackingParams(vehicleNo: _activeVehicleNo, deliveryId: widget.deliveryId))),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.refreshLocation),
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
    final locationStr = location.locationName ?? 'Tracking Live GPS';

    Set<Polyline> polylines = {};
    if (trip != null && trip.sourceLatLong != null && trip.destinationLatLong != null) {
      try {
        final srcParts = trip.sourceLatLong!.split(',');
        final destParts = trip.destinationLatLong!.split(',');
        if (srcParts.length == 2 && destParts.length == 2) {
          final srcLat = double.tryParse(srcParts[0].trim());
          final srcLng = double.tryParse(srcParts[1].trim());
          final destLat = double.tryParse(destParts[0].trim());
          final destLng = double.tryParse(destParts[1].trim());
          
          if (srcLat != null && srcLng != null && destLat != null && destLng != null) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: [LatLng(srcLat, srcLng), LatLng(destLat, destLng)],
                color: Colors.blueAccent,
                width: 5,
              ),
            );
          }
        }
      } catch (_) {}
    }

    return Container(
      color: const Color(0xFFE2E8F0),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.tryParse(location.latitude?.toString() ?? '') ?? 0.0, 
                double.tryParse(location.longitude?.toString() ?? '') ?? 0.0
              ),
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            polylines: polylines,
            markers: {
              if (location.latitude != null && location.longitude != null)
                Marker(
                  markerId: const MarkerId('vehicle_marker'),
                  position: LatLng(
                    double.tryParse(location.latitude?.toString() ?? '') ?? 0.0, 
                    double.tryParse(location.longitude?.toString() ?? '') ?? 0.0
                  ),
                  anchor: const Offset(0.5, 0.5),
                  icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  infoWindow: InfoWindow(
                    title: '${location.vehicleNo ?? _activeVehicleNo} ($speedText)',
                    snippet: locationStr,
                  ),
                ),
            },
          ),



        ],
      ),
    );
  }

  Widget _buildVehicleHeaderCard(VehicleLocationData location, VehicleTripData? trip, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                '${location.vehTypeName ?? AppLocalizations.of(context)!.vehicle} · '
                '${trip?.materialType ?? 'Material N/A'} · '
                '${trip?.quantity ?? location.capacity ?? '0'} ${trip?.mineralUnit ?? 'Units'}',
                style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBannerCard(VehicleLocationData location, BuildContext context) {
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
                Text(
                  AppLocalizations.of(context)!.currentGpsLocation,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF134280), letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  location.locationName ?? AppLocalizations.of(context)!.trackingLiveGps,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppLocalizations.of(context)!.speed}: ${location.speed ?? 0} km/h · ${AppLocalizations.of(context)!.lastUpdated}: ${AppDateFormatter.formatDateTime(location.deviceDatetime)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(VehicleTripData trip, BuildContext context) {
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
              Row(
                children: [
                  const Icon(Icons.route, size: 18, color: AppColors.primary700),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.tripDetails,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                  '${AppLocalizations.of(context)!.tripId}: ${trip.tripID ?? 'N/A'}',
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
                    Text(AppLocalizations.of(context)!.originQuarryPlot, style: const TextStyle(fontSize: 10.5, color: AppColors.inkMuted)),
                    Text(
                      '${trip.plotName ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.destinationSite, style: const TextStyle(fontSize: 10.5, color: AppColors.inkMuted)),
                    Text(
                      trip.destination ?? 'Destination unspecified',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    if (trip.distance != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${AppLocalizations.of(context)!.totalDistance}: ${trip.distance} km',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF134280)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Trip metadata chips


          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.validFrom}: ${AppDateFormatter.formatDateTime(trip.validityFrom)}',
                style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppLocalizations.of(context)!.validUpto}: ${AppDateFormatter.formatDateTime(trip.validityUpto)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary700),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildNoTripCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.inkSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.noActiveDigiTpTripDetails,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDriverActionCard(VehicleLocationData location, VehicleTripData? trip, BuildContext context) {
    final driverName =  trip?.driverName ?? AppLocalizations.of(context)!.driver;
    final driverMobile =  trip?.driverMobNo ?? '';

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
                    driverMobile.isNotEmpty ? driverMobile : AppLocalizations.of(context)!.mobileNumberUnavailable,
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

}
