import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/location_models.dart';

class LocationSelectionData {
  final DistrictModel? district;
  final TalukaModel? taluka;
  final VillageCityModel? villageCity;
  final bool isTown; // false for Rural (Village), true for Urban (City)
  final String category; // 'RURAL' or 'URBAN'

  const LocationSelectionData({
    this.district,
    this.taluka,
    this.villageCity,
    required this.isTown,
    required this.category,
  });

  String get districtName => district?.district ?? '';
  String get talukaName => taluka?.taluka ?? '';
  String get villageCityName => villageCity?.name ?? '';
  int? get districtId => district?.id;
  int? get talukaId => taluka?.id;
  int? get censusId => villageCity?.id;
}

class LocationDropdownSection extends ConsumerStatefulWidget {
  final String initialCategory; // 'RURAL' or 'URBAN'
  final int? initialDistrictId;
  final int? initialTalukaId;
  final int? initialCensusId;
  final String? initialDistrict;
  final String? initialTaluka;
  final String? initialVillageCity;
  final bool showCategorySelector;
  final ValueChanged<LocationSelectionData> onChanged;

  const LocationDropdownSection({
    super.key,
    this.initialCategory = 'URBAN',
    this.initialDistrictId,
    this.initialTalukaId,
    this.initialCensusId,
    this.initialDistrict,
    this.initialTaluka,
    this.initialVillageCity,
    this.showCategorySelector = true,
    required this.onChanged,
  });

  @override
  ConsumerState<LocationDropdownSection> createState() =>
      _LocationDropdownSectionState();
}

class _LocationDropdownSectionState
    extends ConsumerState<LocationDropdownSection> {
  late String _category; // 'RURAL' | 'URBAN'
  bool get _isTown =>
      _category == 'URBAN'; // Rural -> isTown = false, Urban -> isTown = true

  List<DistrictModel> _districts = [];
  List<TalukaModel> _talukas = [];
  List<VillageCityModel> _villageCities = [];

  DistrictModel? _selectedDistrict;
  TalukaModel? _selectedTaluka;
  VillageCityModel? _selectedVillageCity;

  bool _loadingDistricts = false;
  bool _loadingTalukas = false;
  bool _loadingVillageCities = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() => _loadingDistricts = true);
    final repo = ref.read(locationRepositoryProvider);
    final districts = await repo.getDistricts();

    if (!mounted) return;

    DistrictModel? matchedDistrict;
    if (widget.initialDistrictId != null && widget.initialDistrictId! > 0) {
      matchedDistrict = districts.firstWhere(
        (d) => d.id == widget.initialDistrictId,
        orElse: () => districts.firstWhere(
          (d) =>
              widget.initialDistrict != null &&
              d.district.trim().toLowerCase() ==
                  widget.initialDistrict!.trim().toLowerCase(),
          orElse: () => districts.isNotEmpty
              ? districts.first
              : const DistrictModel(id: 1, district: 'Pune'),
        ),
      );
    } else if (widget.initialDistrict != null && widget.initialDistrict!.isNotEmpty) {
      matchedDistrict = districts.firstWhere(
        (d) =>
            d.district.trim().toLowerCase() ==
            widget.initialDistrict!.trim().toLowerCase(),
        orElse: () => districts.isNotEmpty
            ? districts.first
            : const DistrictModel(id: 1, district: 'Pune'),
      );
    }


    setState(() {
      _districts = districts;
      _selectedDistrict = matchedDistrict;
      _loadingDistricts = false;
    });

    if (_selectedDistrict != null) {
      _loadTalukas(_selectedDistrict!.id);
    }
  }

  Future<void> _loadTalukas(int districtId) async {
    setState(() {
      _loadingTalukas = true;
      _talukas = [];
      _selectedTaluka = null;
      _villageCities = [];
      _selectedVillageCity = null;
    });

    final repo = ref.read(locationRepositoryProvider);
    final talukas = await repo.getTalukas(districtId);

    if (!mounted) return;

    TalukaModel? matchedTaluka;
    if (widget.initialTalukaId != null && widget.initialTalukaId! > 0) {
      matchedTaluka = talukas.firstWhere(
        (t) => t.id == widget.initialTalukaId,
        orElse: () => talukas.firstWhere(
          (t) =>
              widget.initialTaluka != null &&
              t.taluka.trim().toLowerCase() ==
                  widget.initialTaluka!.trim().toLowerCase(),
          orElse: () => talukas.isNotEmpty
              ? talukas.first
              : TalukaModel(id: 232, taluka: 'Haveli', districtId: districtId),
        ),
      );
    } else if (widget.initialTaluka != null && widget.initialTaluka!.isNotEmpty) {
      matchedTaluka = talukas.firstWhere(
        (t) =>
            t.taluka.trim().toLowerCase() ==
            widget.initialTaluka!.trim().toLowerCase(),
        orElse: () => talukas.isNotEmpty
            ? talukas.first
            : TalukaModel(id: 232, taluka: 'Haveli', districtId: districtId),
      );
    }


    setState(() {
      _talukas = talukas;
      _selectedTaluka = matchedTaluka;
      _loadingTalukas = false;
    });

    _notifyChange();

    if (_selectedDistrict != null && _selectedTaluka != null) {
      _loadVillageCities(_selectedDistrict!.id, _selectedTaluka!.id, _isTown);
    }
  }

  Future<void> _loadVillageCities(
      int districtId, int talukaId, bool isTown) async {
    setState(() {
      _loadingVillageCities = true;
      _villageCities = [];
      _selectedVillageCity = null;
    });

    final repo = ref.read(locationRepositoryProvider);
    final items = await repo.getVillageCities(
      districtId: districtId,
      talukaId: talukaId,
      isTown: isTown,
    );

    if (!mounted) return;

    VillageCityModel? matchedItem;
    if (widget.initialCensusId != null && widget.initialCensusId! > 0) {
      matchedItem = items.firstWhere(
        (v) => v.id == widget.initialCensusId,
        orElse: () => items.firstWhere(
          (v) =>
              widget.initialVillageCity != null &&
              v.name.trim().toLowerCase() ==
                  widget.initialVillageCity!.trim().toLowerCase(),
          orElse: () => items.isNotEmpty
              ? items.first
              : VillageCityModel(
                  id: widget.initialCensusId!,
                  name: widget.initialVillageCity ?? 'Location #',
                  districtId: districtId,
                  talukaId: talukaId,
                  isTown: isTown),
        ),
      );
    } else if (widget.initialVillageCity != null &&
        widget.initialVillageCity!.isNotEmpty) {
      matchedItem = items.firstWhere(
        (v) =>
            v.name.trim().toLowerCase() ==
            widget.initialVillageCity!.trim().toLowerCase(),
        orElse: () => items.isNotEmpty
            ? items.first
            : VillageCityModel(
                id: 101,
                name: widget.initialVillageCity!,
                districtId: districtId,
                talukaId: talukaId,
                isTown: isTown),
      );
    }


    setState(() {
      _villageCities = items;
      _selectedVillageCity = matchedItem;
      _loadingVillageCities = false;
    });

    _notifyChange();
  }

  void _onCategoryChanged(String newCat) {
    if (_category == newCat) return;
    setState(() {
      _category = newCat;
    });

    if (_selectedDistrict != null && _selectedTaluka != null) {
      _loadVillageCities(_selectedDistrict!.id, _selectedTaluka!.id, _isTown);
    } else {
      _notifyChange();
    }
  }

  void _notifyChange() {
    widget.onChanged(
      LocationSelectionData(
        district: _selectedDistrict,
        taluka: _selectedTaluka,
        villageCity: _selectedVillageCity,
        isTown: _isTown,
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villageCityLabel = _isTown ? 'City / Corporation' : 'Village / Rural Area';
    final villageCityHint =
        _isTown ? 'e.g. Pune City (PMC)' : 'e.g. Narayangaon';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Urban / Rural Pill Selector
        if (widget.showCategorySelector) ...[
          const Text('Area Classification',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onCategoryChanged('URBAN'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isTown
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isTown
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFCBD5E1),
                        width: _isTown ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_city_outlined,
                            size: 16,
                            color: _isTown
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Urban (City)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isTown
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _onCategoryChanged('RURAL'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isTown
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: !_isTown
                            ? const Color(0xFF059669)
                            : const Color(0xFFCBD5E1),
                        width: !_isTown ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.holiday_village_outlined,
                            size: 16,
                            color: !_isTown
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Rural (Village)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: !_isTown
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // District Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('District *',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink)),
            const SizedBox(height: 6),
            _loadingDistricts
                ? Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line),
                      color: AppColors.surface,
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Loading Districts...',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.inkMuted)),
                      ],
                    ),
                  )
                : DropdownButtonFormField<DistrictModel>(
                    initialValue: _selectedDistrict,
                    isExpanded: true,
                    hint: const Text('Select District',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.inkMuted)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.line)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.line)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 1.5)),
                    ),
                    items: _districts.map((d) {
                      return DropdownMenuItem<DistrictModel>(
                        value: d,
                        child: Text(d.district,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (newDistrict) {
                      if (newDistrict == null ||
                          newDistrict == _selectedDistrict) { return; }
                      setState(() => _selectedDistrict = newDistrict);
                      _loadTalukas(newDistrict.id);
                    },
                  ),
          ],
        ),
        const SizedBox(height: 14),

        // Taluka & Village/City Dropdowns Row
        Row(
          children: [
            // Taluka Dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Taluka *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink)),
                  const SizedBox(height: 6),
                  _loadingTalukas
                      ? Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.line),
                            color: AppColors.surface,
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              SizedBox(width: 6),
                              Text('Loading...',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<TalukaModel>(
                          initialValue: _selectedTaluka,
                          isExpanded: true,
                          hint: const Text('e.g. Haveli',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.inkMuted),
                              overflow: TextOverflow.ellipsis),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.line)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.line)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2563EB), width: 1.5)),
                          ),
                          items: _talukas.map((t) {
                            return DropdownMenuItem<TalukaModel>(
                              value: t,
                              child: Text(t.taluka,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (newTaluka) {
                            if (newTaluka == null ||
                                newTaluka == _selectedTaluka) { return; }
                            setState(() => _selectedTaluka = newTaluka);
                            if (_selectedDistrict != null) {
                              _loadVillageCities(
                                  _selectedDistrict!.id, newTaluka.id, _isTown);
                            }
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Village / City Dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(villageCityLabel,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink)),
                  const SizedBox(height: 6),
                  _loadingVillageCities
                      ? Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.line),
                            color: AppColors.surface,
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              SizedBox(width: 6),
                              Text('Loading...',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<VillageCityModel>(
                          initialValue: _selectedVillageCity,
                          isExpanded: true,
                          hint: Text(villageCityHint,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.inkMuted),
                              overflow: TextOverflow.ellipsis),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.line)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.line)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2563EB), width: 1.5)),
                          ),
                          items: _villageCities.map((v) {
                            return DropdownMenuItem<VillageCityModel>(
                              value: v,
                              child: Text(v.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (newVc) {
                            if (newVc == null) return;
                            setState(() => _selectedVillageCity = newVc);
                            _notifyChange();
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
