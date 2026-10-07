import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/location_models.dart';
import '../../providers/session_provider.dart';
import '../../l10n/app_localizations.dart';

class LocationSelectionData {
  final StateModel? state;
  final DistrictModel? district;
  final TalukaModel? taluka;
  final VillageCityModel? villageCity;
  final bool isTown; // false for Rural (Village), true for Urban (City)
  final String? category; // 'RURAL' or 'URBAN'

  const LocationSelectionData({
    this.state,
    this.district,
    this.taluka,
    this.villageCity,
    required this.isTown,
    this.category,
  });

  String get stateName => state?.state ?? '';
  String get districtName => district?.district ?? '';
  String get talukaName => taluka?.taluka ?? '';
  String get villageCityName => villageCity?.name ?? '';
  int? get stateId => state?.id;
  int? get districtId => district?.id;
  int? get talukaId => taluka?.id;
  int? get censusId => villageCity?.id;
}

class LocationDropdownSection extends ConsumerStatefulWidget {
  final String? initialCategory; // 'RURAL' or 'URBAN' or null
  final int? initialStateId;
  final int? initialDistrictId;
  final int? initialTalukaId;
  final int? initialCensusId;
  final String? initialState;
  final String? initialDistrict;
  final String? initialTaluka;
  final String? initialVillageCity;
  final bool showCategorySelector;
  final ValueChanged<LocationSelectionData> onChanged;
  final String? stateError;
  final String? districtError;
  final String? talukaError;
  final String? villageCityError;

  const LocationDropdownSection({
    super.key,
    this.initialCategory,
    this.initialStateId,
    this.initialDistrictId,
    this.initialTalukaId,
    this.initialCensusId,
    this.initialState,
    this.initialDistrict,
    this.initialTaluka,
    this.initialVillageCity,
    this.showCategorySelector = true,
    required this.onChanged,
    this.stateError,
    this.districtError,
    this.talukaError,
    this.villageCityError,
  });

  @override
  ConsumerState<LocationDropdownSection> createState() =>
      _LocationDropdownSectionState();
}

class _LocationDropdownSectionState
    extends ConsumerState<LocationDropdownSection> {
  String? _category; // 'RURAL' | 'URBAN' | null
  bool get _isTown => _category == 'URBAN'; // Rural -> isTown = false, Urban -> isTown = true
  bool get _isRural => _category == 'RURAL';

  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  List<TalukaModel> _talukas = [];
  List<VillageCityModel> _villageCities = [];

  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;
  TalukaModel? _selectedTaluka;
  VillageCityModel? _selectedVillageCity;

  bool _loadingStates = false;
  bool _loadingDistricts = false;
  bool _loadingTalukas = false;
  bool _loadingVillageCities = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    final repo = ref.read(locationRepositoryProvider);
    final states = await repo.getStates();

    if (!mounted) return;

    StateModel? matchedState;
    if (widget.initialStateId != null && widget.initialStateId! > 0) {
      matchedState = states.firstWhere(
        (s) => s.id == widget.initialStateId,
        orElse: () => states.firstWhere(
          (s) =>
              widget.initialState != null &&
              s.state.trim().toLowerCase() ==
                  widget.initialState!.trim().toLowerCase(),
          orElse: () => states.isNotEmpty
              ? states.firstWhere((s) => s.id == 1, orElse: () => states.first)
              : const StateModel(id: 1, state: 'Maharashtra', stateCode: 11),
        ),
      );
    } else if (widget.initialState != null && widget.initialState!.isNotEmpty) {
      matchedState = states.firstWhere(
        (s) =>
            s.state.trim().toLowerCase() ==
            widget.initialState!.trim().toLowerCase(),
        orElse: () => states.isNotEmpty
            ? states.firstWhere((s) => s.id == 1, orElse: () => states.first)
            : const StateModel(id: 1, state: 'Maharashtra', stateCode: 11),
      );
    } else {
       matchedState = states.isNotEmpty
            ? states.firstWhere((s) => s.id == 1, orElse: () => states.first)
            : const StateModel(id: 1, state: 'Maharashtra', stateCode: 11);
    }

    setState(() {
      _states = states;
      _selectedState = matchedState;
      _loadingStates = false;
    });

    if (_selectedState != null) {
      _loadDistricts(_selectedState!.id);
    }
  }

  Future<void> _loadDistricts(int stateId) async {
    setState(() {
      _loadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
      _talukas = [];
      _selectedTaluka = null;
      _villageCities = [];
      _selectedVillageCity = null;
    });
    final repo = ref.read(locationRepositoryProvider);
    final districts = await repo.getDistricts(stateId);

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
    try {
      if (widget.initialTalukaId != null && widget.initialTalukaId! > 0) {
        matchedTaluka = talukas.firstWhere((t) => t.id == widget.initialTalukaId);
      } else if (widget.initialTaluka != null && widget.initialTaluka!.isNotEmpty) {
        matchedTaluka = talukas.firstWhere((t) => t.taluka.trim().toLowerCase() == widget.initialTaluka!.trim().toLowerCase());
      }
    } catch (_) {
      matchedTaluka = null;
    }


    setState(() {
      _talukas = talukas;
      _selectedTaluka = matchedTaluka;
      _loadingTalukas = false;
    });

    _notifyChange();

    if (_isTown) {
      if (_selectedDistrict != null) {
        _loadVillageCities(_selectedDistrict!.id, 0, _isTown);
      }
    } else {
      if (_selectedDistrict != null && _selectedTaluka != null) {
        _loadVillageCities(_selectedDistrict!.id, _selectedTaluka!.id, _isTown);
      }
    }
  }

  Future<void> _loadVillageCities(
      int districtId, int talukaId, bool isTown) async {
    setState(() {
      _loadingVillageCities = true;
      _villageCities = [];
      _selectedVillageCity = null;
    });

    final user = ref.read(sessionProvider).currentUser;
    final userId = user != null ? int.tryParse(user.id) ?? 0 : 0;

    final repo = ref.read(locationRepositoryProvider);
    final items = await repo.getVillageCities(
      districtId: districtId,
      talukaId: talukaId,
      isTown: isTown,
      userId: userId,
    );

    if (!mounted) return;

    VillageCityModel? matchedItem;
    try {
      if (widget.initialCensusId != null && widget.initialCensusId! > 0) {
        matchedItem = items.firstWhere((v) => v.id == widget.initialCensusId);
      } else if (widget.initialVillageCity != null && widget.initialVillageCity!.isNotEmpty) {
        matchedItem = items.firstWhere((v) => v.name.trim().toLowerCase() == widget.initialVillageCity!.trim().toLowerCase());
      }
    } catch (_) {
      matchedItem = null;
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
      _selectedVillageCity = null;
    });

    if (_isTown) {
      if (_selectedDistrict != null) {
        _loadVillageCities(_selectedDistrict!.id, 0, _isTown);
      } else {
        _notifyChange();
      }
    } else {
      if (_selectedDistrict != null && _selectedTaluka != null) {
        _loadVillageCities(_selectedDistrict!.id, _selectedTaluka!.id, _isTown);
      } else {
        _notifyChange();
      }
    }
  }

  void _notifyChange() {
    widget.onChanged(
      LocationSelectionData(
        state: _selectedState,
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
    final l10n = AppLocalizations.of(context)!;
    final villageCityLabel = _isTown ? l10n.cityCorporationLabel : l10n.villageRuralLabel;
    final villageCityHint =
        _isTown ? l10n.cityCorporationHint : l10n.villageRuralHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Urban / Rural Pill Selector
        if (widget.showCategorySelector) ...[
          Text(l10n.areaClassificationLabel,
              style: const TextStyle(
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
                          l10n.urbanCity,
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
                      color: _isRural
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isRural
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFCBD5E1),
                        width: _isRural ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.holiday_village_outlined,
                            size: 16,
                            color: _isRural
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          l10n.ruralVillage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isRural
                                ? const Color(0xFF2563EB)
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

        // State Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.stateLabel,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink)),
            const SizedBox(height: 6),
            _loadingStates
                ? Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line),
                      color: AppColors.surface,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text(l10n.loadingStates,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.inkMuted)),
                      ],
                    ),
                  )
                : DropdownButtonFormField<StateModel>(
                    initialValue: _selectedState,
                    isExpanded: true,
                    hint: Text(l10n.selectStateHint,
                        style: const TextStyle(
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
                      errorText: widget.stateError,
                      errorMaxLines: 3,
                    ),
                    items: _states.map((s) {
                      return DropdownMenuItem<StateModel>(
                        value: s,
                        child: Text(s.state,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (StateModel? newValue) {
                      setState(() {
                        _selectedState = newValue;
                        _selectedDistrict = null;
                        _selectedTaluka = null;
                        _selectedVillageCity = null;
                      });
                      if (newValue != null) {
                        _loadDistricts(newValue.id);
                      }
                      _notifyChange();
                    },
                  ),
          ],
        ),
        const SizedBox(height: 16),

        // District Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.districtLabel,
                style: const TextStyle(
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
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text(l10n.loadingDistricts,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.inkMuted)),
                      ],
                    ),
                  )
                : DropdownButtonFormField<DistrictModel>(
                    initialValue: _selectedDistrict,
                    isExpanded: true,
                    hint: Text(l10n.selectDistrictHint,
                        style: const TextStyle(
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
                      errorText: widget.districtError,
                      errorMaxLines: 3,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Taluka Dropdown
            if (!_isTown) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.talukaLabel,
                      style: const TextStyle(
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
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              const SizedBox(width: 6),
                              Text(l10n.loading,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<TalukaModel>(
                          initialValue: _selectedTaluka,
                          isExpanded: true,
                          hint: Text(l10n.talukaHint,
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
                            errorText: widget.talukaError,
                            errorMaxLines: 3,
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
            ],

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
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              const SizedBox(width: 6),
                              Text(l10n.loading,
                                  style: const TextStyle(
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
                            errorText: widget.villageCityError,
                            errorMaxLines: 3,
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
