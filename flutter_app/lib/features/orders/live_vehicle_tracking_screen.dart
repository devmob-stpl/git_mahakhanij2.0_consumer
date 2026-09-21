import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_badge.dart';

class LiveVehicleTrackingScreen extends StatefulWidget {
  final String deliveryId;

  const LiveVehicleTrackingScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<LiveVehicleTrackingScreen> createState() => _LiveVehicleTrackingScreenState();
}

class _LiveVehicleTrackingScreenState extends State<LiveVehicleTrackingScreen> {
  double _sheetSize = 0.45; // Half expanded by default (peek: 0.18, half: 0.45, full: 0.85)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live vehicle tracking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            Text(
              'DTP-2024-8842 · In Transit',
              style: TextStyle(fontSize: 11, color: AppColors.inkSecondary),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.line),
        ),
      ),
      body: Stack(
        children: [
          // 1. Simulated Interactive Map Canvas
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE2E8F0),
              child: Stack(
                children: [
                  // Map background grid illustration
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MapCanvasPainter(),
                  ),
                  // Vehicle marker with radar ping
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _PulsingVehicleMarker(),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: const Text(
                            'MH-15-BN-4402 (38 km/h)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Draggable Bottom Drawer
          DraggableScrollableSheet(
            initialChildSize: _sheetSize,
            minChildSize: 0.16,
            maxChildSize: 0.85,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Center drag pill
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

                    // Top Overview Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'MH-15-BN-4402',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'River Sand · 12 Brass',
                              style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F0FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'In Transit',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7E22CE)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 14),

                    // Route Progress & ETA
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF5FD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD6E5F8)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.near_me, color: Color(0xFF1241A6), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Arrival: 18 mins (4.8 km)',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF134280)),
                                ),
                                Text(
                                  'Transit speed ~42 km/h along NH-48 Expressway',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Source & Destination Flow
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.radio_button_checked, size: 16, color: AppColors.primary700),
                            SizedBox(
                              height: 36,
                              child: VerticalDivider(thickness: 1.5, color: AppColors.line),
                            ),
                            Icon(Icons.location_on, size: 16, color: Color(0xFFEF4444)),
                          ],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Source Quarry', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                              Text('Godavari Sand Ghat, Nashik Block 4', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                              SizedBox(height: 18),
                              Text('Destination Site', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                              Text('NH-48 Road Widening Site, Thane', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Driver Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFEEF4FE),
                                child: Icon(Icons.person, color: Color(0xFF1241A6), size: 20),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nitin Wagh', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                  Text('9689330214 · Omkar Logistics', style: TextStyle(fontSize: 11, color: AppColors.inkSecondary)),
                                ],
                              ),
                            ],
                          ),
                          Icon(Icons.phone_in_talk, color: Color(0xFF1241A6), size: 22),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'View DigiTP Pass',
                            variant: AppButtonVariant.secondary,
                            icon: const Icon(Icons.qr_code, size: 16),
                            onPressed: () => context.push('/activity'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'Gate Receiving',
                            icon: const Icon(Icons.qr_code_scanner, size: 16),
                            onPressed: () => context.push('/receive'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PulsingVehicleMarker extends StatelessWidget {
  const _PulsingVehicleMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1241A6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: const Icon(Icons.local_shipping, color: Colors.white, size: 22),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.15)
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.3,
        size.width * 0.2,
        size.height * 0.7,
        size.width * 0.85,
        size.height * 0.85,
      );

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
