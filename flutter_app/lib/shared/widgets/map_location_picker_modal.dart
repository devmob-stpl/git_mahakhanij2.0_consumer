import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class MapLocationPickerModal extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String? initialAddress;
  final String? district;
  final String? taluka;
  final String? village;

  const MapLocationPickerModal({
    super.key,
    this.initialLat = 18.520430,
    this.initialLng = 73.856740,
    this.initialAddress,
    this.district,
    this.taluka,
    this.village,
  });

  static Future<LocationPickerResult?> show(
    BuildContext context, {
    double initialLat = 18.520430,
    double initialLng = 73.856740,
    String? initialAddress,
    String? district,
    String? taluka,
    String? village,
  }) {
    return showModalBottomSheet<LocationPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MapLocationPickerModal(
        initialLat: initialLat,
        initialLng: initialLng,
        initialAddress: initialAddress,
        district: district,
        taluka: taluka,
        village: village,
      ),
    );
  }

  @override
  State<MapLocationPickerModal> createState() => _MapLocationPickerModalState();
}

class _MapLocationPickerModalState extends State<MapLocationPickerModal> {
  late double _currentLat;
  late double _currentLng;
  late TextEditingController _addressController;
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  int _selectedMapType = 0; // 0: Default Map, 1: Satellite, 2: Terrain
  List<Map<String, dynamic>> _searchResults = [];
  bool _showSearchResults = false;

  // Searchable locations dataset (Cities, Landmarks, MIDCs, Infrastructure Sites)
  static const List<Map<String, dynamic>> _searchablePlaces = [
    {'title': 'Plot 42, Baner Link Road', 'subtitle': 'Baner, Haveli, Pune', 'lat': 18.5590, 'lng': 73.7868},
    {'title': 'Hinjawadi IT Park Phase 1', 'subtitle': 'Hinjawadi, Mulshi, Pune', 'lat': 18.5912, 'lng': 73.7389},
    {'title': 'Civil Court Metro Station', 'subtitle': 'Shivajinagar, Haveli, Pune', 'lat': 18.5204, 'lng': 73.8567},
    {'title': 'Quarry Gate Site 12', 'subtitle': 'Katraj, Haveli, Pune', 'lat': 18.4996, 'lng': 73.8648},
    {'title': 'MIDC Chakan Phase II Plot 105', 'subtitle': 'Chakan, Khed, Pune', 'lat': 18.6298, 'lng': 73.7997},
    {'title': 'Wagholi Survey No 42', 'subtitle': 'Wagholi, Haveli, Pune', 'lat': 18.5808, 'lng': 73.9787},
    {'title': 'Magarpatta Cybercity Plot 18', 'subtitle': 'Hadapsar, Haveli, Pune', 'lat': 18.5158, 'lng': 73.9272},
    {'title': 'Vashi Sector 17 Commercial Hub', 'subtitle': 'Vashi, Navi Mumbai, Thane', 'lat': 19.0770, 'lng': 72.9986},
    {'title': 'BKC G-Block Complex', 'subtitle': 'Bandra East, Mumbai Suburban', 'lat': 19.0657, 'lng': 72.8686},
    {'title': 'CIDCO Waluj Industrial Area', 'subtitle': 'Waluj, Chhatrapati Sambhajinagar', 'lat': 19.8340, 'lng': 75.2505},
    {'title': 'MIDC Ambad Auto Hub', 'subtitle': 'Ambad, Nashik', 'lat': 19.9575, 'lng': 73.7431},
    {'title': 'Kamptee Road Logistics Park', 'subtitle': 'Kamptee, Nagpur', 'lat': 21.2008, 'lng': 79.1176},
    {'title': 'Shirdi MIDC Infrastructure Plot', 'subtitle': 'Rahata, Ahilyanagar', 'lat': 19.7667, 'lng': 74.4764},
    {'title': 'Pirangut Industrial Estate Plot 33', 'subtitle': 'Pirangut, Mulshi, Pune', 'lat': 18.5102, 'lng': 73.6811},
    {'title': 'Loni Kalbhor Highway Site 8', 'subtitle': 'Loni Kalbhor, Haveli, Pune', 'lat': 18.4854, 'lng': 74.0205},
    {'title': 'Khed Rajgurunagar Auto Corridor', 'subtitle': 'Khed, Pune', 'lat': 18.8550, 'lng': 73.8820},
  ];

  // Quick preset location markers around Pune / Maharashtra for quick testing
  final List<Map<String, dynamic>> _presets = [
    {'name': 'Plot 42, Baner Link Rd', 'lat': 18.5590, 'lng': 73.7868, 'area': 'Baner, Pune'},
    {'name': 'Quarry Gate Site 12', 'lat': 18.4996, 'lng': 73.8648, 'area': 'Katraj, Pune'},
    {'name': 'Interchange Plot 8', 'lat': 18.5204, 'lng': 73.8567, 'area': 'Shivajinagar, Pune'},
    {'name': 'MIDC Phase II Plot 105', 'lat': 18.6298, 'lng': 73.7997, 'area': 'Pimpri-Chinchwad'},
  ];

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;

    final defaultAddr = widget.initialAddress != null && widget.initialAddress!.isNotEmpty
        ? widget.initialAddress!
        : _generateAddress(_currentLat, _currentLng, widget.village, widget.taluka, widget.district);

    _addressController = TextEditingController(text: defaultAddr);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _generateAddress(double lat, double lng, String? village, String? taluka, String? district) {
    final v = (village != null && village.isNotEmpty) ? village : 'Baner Site';
    final t = (taluka != null && taluka.isNotEmpty) ? taluka : 'Haveli';
    final d = (district != null && district.isNotEmpty) ? district : 'Pune';
    return 'Plot No. ${(lat * 1000).toInt() % 50 + 1}, $v, $t, $d (Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)})';
  }

  void _updateLocation(double lat, double lng, [String? customArea]) {
    setState(() {
      _currentLat = lat;
      _currentLng = lng;
      _showSearchResults = false;
      final areaStr = customArea ?? widget.village;
      _addressController.text = _generateAddress(lat, lng, areaStr, widget.taluka, widget.district);
    });
  }

  void _useCurrentLocation() {
    _updateLocation(18.520430, 73.856740, 'GPS Current Site');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.msgGpsCaptured)),
    );
  }

  void _onSearchQueryChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final matches = _searchablePlaces.where((place) {
      final title = (place['title'] as String).toLowerCase();
      final subtitle = (place['subtitle'] as String).toLowerCase();
      return title.contains(q) || subtitle.contains(q);
    }).toList();

    if (matches.isEmpty) {
      final hash = q.codeUnits.fold(0, (acc, c) => acc + c);
      final customLat = 18.5000 + (hash % 200) * 0.001;
      final customLng = 73.8000 + (hash % 300) * 0.001;
      matches.add({
        'title': query.trim(),
        'subtitle': '${widget.village ?? "Baner"}, ${widget.taluka ?? "Haveli"}, ${widget.district ?? "Pune"}',
        'lat': double.parse(customLat.toStringAsFixed(5)),
        'lng': double.parse(customLng.toStringAsFixed(5)),
      });
    }

    setState(() {
      _searchResults = matches;
      _showSearchResults = true;
    });
  }

  void _selectSearchResult(Map<String, dynamic> location) {
    final lat = location['lat'] as double;
    final lng = location['lng'] as double;
    final title = location['title'] as String;
    final subtitle = location['subtitle'] as String;

    final fullAddress = '$title, $subtitle (Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)})';

    setState(() {
      _currentLat = lat;
      _currentLng = lng;
      _searchController.text = title;
      _addressController.text = fullAddress;
      _showSearchResults = false;
    });

    _searchFocusNode.unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location selected: $title (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      margin: EdgeInsets.only(bottom: keyboardHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.map_outlined, color: AppColors.primary700, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Maps Location Picker',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        Text(
                          'Search location or drag pin to set site coordinates',
                          style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.inkSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),

          // Interactive Map Canvas Area
          Expanded(
            child: Stack(
              children: [
                // Simulated Map Background with Grid / Coordinates
                GestureDetector(
                  onTapUp: (details) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final localPos = details.localPosition;
                    final double deltaLat = ((box.size.height / 2) - localPos.dy) * 0.0002;
                    final double deltaLng = (localPos.dx - (box.size.width / 2)) * 0.0002;
                    _updateLocation(_currentLat + deltaLat, _currentLng + deltaLng);
                  },
                  child: Container(
                    color: _selectedMapType == 1
                        ? const Color(0xFF1E293B) // Dark Satellite Mode
                        : (_selectedMapType == 2 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0)),
                    child: Stack(
                      children: [
                        // Map Grid / Terrain Pattern Background
                        CustomPaint(
                          size: Size.infinite,
                          painter: MapGridPainter(isSatellite: _selectedMapType == 1),
                        ),

                        // Map Pins & Preset Locations
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Floating Coordinate Badge above Pin
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.ink,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Text(
                                  '${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'monospace'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Draggable Pin Marker Icon
                              const Icon(
                                Icons.location_on,
                                size: 44,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(height: 36), // Alignment offset for pin tip
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map Overlay: Search Location Input & Dropdown Suggestions
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Column(
                    children: [
                      // Search Input Box
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchQueryChanged,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                          decoration: InputDecoration(
                            hintText: 'Search place, landmark, survey plot...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                            prefixIcon: const Icon(Icons.search, color: AppColors.primary700, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: AppColors.inkSecondary),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),

                      // Search Suggestions Dropdown Overlay
                      if (_showSearchResults && _searchResults.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 210),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (ctx, index) {
                              final item = _searchResults[index];
                              final lat = item['lat'] as double;
                              final lng = item['lng'] as double;
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.location_on, color: AppColors.primary700, size: 18),
                                ),
                                title: Text(
                                  item['title'] as String,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                                ),
                                subtitle: Text(
                                  '${item['subtitle']} • (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
                                  style: const TextStyle(fontSize: 10, color: AppColors.inkSecondary),
                                ),
                                onTap: () => _selectSearchResult(item),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Map Layer Controls (Satellite vs Map vs Terrain)
                Positioned(
                  top: _showSearchResults ? 270 : 66,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMapTypePill(0, 'Map'),
                        const SizedBox(width: 4),
                        _buildMapTypePill(1, 'Satellite'),
                        const SizedBox(width: 4),
                        _buildMapTypePill(2, 'Terrain'),
                      ],
                    ),
                  ),
                ),

                // My GPS Button
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'gps_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary700,
                    onPressed: _useCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // Quick Preset Sites Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QUICK LOCATIONS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _presets.map((preset) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.place_outlined, size: 14, color: AppColors.primary700),
                          label: Text(preset['name'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          onPressed: () => _updateLocation(preset['lat'] as double, preset['lng'] as double, preset['area'] as String),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Reverse Geocoded Address Preview & Confirmation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Address / Landmark', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary700)),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Confirm Location & Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      final result = LocationPickerResult(
                        latitude: _currentLat,
                        longitude: _currentLng,
                        address: _addressController.text.trim(),
                      );
                      Navigator.of(context).pop(result);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTypePill(int index, String label) {
    final isSelected = _selectedMapType == index;
    return InkWell(
      onTap: () => setState(() => _selectedMapType = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary700 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.inkSecondary,
          ),
        ),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final bool isSatellite;

  MapGridPainter({required this.isSatellite});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSatellite ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;

    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
