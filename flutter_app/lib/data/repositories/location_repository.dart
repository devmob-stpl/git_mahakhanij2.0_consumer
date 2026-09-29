import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/location_models.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

abstract class LocationRepository {
  Future<List<DistrictModel>> getDistricts();
  Future<List<TalukaModel>> getTalukas(int districtId);
  Future<List<VillageCityModel>> getVillageCities({
    required int districtId,
    required int talukaId,
    required bool isTown,
  });
  Future<({String districtName, String talukaName, String villageName})> resolveLocationNames({
    required int? districtId,
    required int? talukaId,
    required int? censusId,
    required bool isTown,
  });
}

class LocationRepositoryImpl implements LocationRepository {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  List<DistrictModel>? _cachedDistricts;
  final Map<int, List<TalukaModel>> _cachedTalukas = {};
  final Map<String, List<VillageCityModel>> _cachedCensus = {};

  @override
  Future<List<DistrictModel>> getDistricts() async {
    if (_cachedDistricts != null && _cachedDistricts!.isNotEmpty) {
      return _cachedDistricts!;
    }

    try {
      final url = ApiEndpoints.getDistrictsUrl();
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic> && data['responseData'] is List) {
        final list = (data['responseData'] as List)
            .map((item) => DistrictModel.fromJson(item as Map<String, dynamic>))
            .where((d) => d.district.trim().isNotEmpty)
            .toList();
        
        list.sort((a, b) => a.district.compareTo(b.district));
        _cachedDistricts = list;
        return _cachedDistricts!;
      }
    } catch (_) {
      // Fallback in case of network issue
    }

    return _fallbackDistricts;
  }

  @override
  Future<List<TalukaModel>> getTalukas(int districtId) async {
    if (_cachedTalukas.containsKey(districtId)) {
      return _cachedTalukas[districtId]!;
    }

    try {
      final url = ApiEndpoints.getTalukasUrl(districtId);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic> && data['responseData'] is List) {
        final list = (data['responseData'] as List)
            .map((item) => TalukaModel.fromJson(item as Map<String, dynamic>))
            .where((t) => t.taluka.trim().isNotEmpty)
            .toList();

        list.sort((a, b) => a.taluka.compareTo(b.taluka));
        _cachedTalukas[districtId] = list;
        return list;
      }
    } catch (_) {
      // Fallback
    }

    return _fallbackTalukas(districtId);
  }

  @override
  Future<List<VillageCityModel>> getVillageCities({
    required int districtId,
    required int talukaId,
    required bool isTown,
  }) async {
    final cacheKey = '$districtId-$talukaId-$isTown';
    if (_cachedCensus.containsKey(cacheKey)) {
      return _cachedCensus[cacheKey]!;
    }

    try {
      final url = ApiEndpoints.getCensusDataUrl(
        districtId: districtId,
        talukaId: talukaId,
        isTown: isTown,
      );
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic> && data['responseData'] is Map) {
        final respMap = data['responseData'] as Map<String, dynamic>;
        if (respMap['data'] is List) {
          final list = (respMap['data'] as List)
              .map((item) => VillageCityModel.fromJson(item as Map<String, dynamic>))
              .where((v) => v.name.trim().isNotEmpty)
              .toList();

          list.sort((a, b) => a.name.compareTo(b.name));
          _cachedCensus[cacheKey] = list;
          return list;
        }
      }
    } catch (_) {
      // Fallback
    }

    return _fallbackVillageCities(districtId, talukaId, isTown);
  }

  @override
  Future<({String districtName, String talukaName, String villageName})> resolveLocationNames({
    required int? districtId,
    required int? talukaId,
    required int? censusId,
    required bool isTown,
  }) async {
    String districtName = '';
    String talukaName = '';
    String villageName = '';

    if (districtId != null && districtId > 0) {
      final districts = await getDistricts();
      final match = districts.firstWhere(
        (d) => d.id == districtId,
        orElse: () => DistrictModel(id: districtId, district: 'District #$districtId', stateId: 1),
      );
      districtName = match.district;
    }

    if (districtId != null && districtId > 0 && talukaId != null && talukaId > 0) {
      final talukas = await getTalukas(districtId);
      final match = talukas.firstWhere(
        (t) => t.id == talukaId,
        orElse: () => TalukaModel(id: talukaId, taluka: 'Taluka #$talukaId', districtId: districtId),
      );
      talukaName = match.taluka;
    }

    if (districtId != null && districtId > 0 && talukaId != null && talukaId > 0 && censusId != null && censusId > 0) {
      final villages = await getVillageCities(districtId: districtId, talukaId: talukaId, isTown: isTown);
      final match = villages.firstWhere(
        (v) => v.id == censusId,
        orElse: () => VillageCityModel(id: censusId, name: 'Village/Town #$censusId', districtId: districtId, talukaId: talukaId, isTown: isTown),
      );
      villageName = match.name;
    }

    return (
      districtName: districtName,
      talukaName: talukaName,
      villageName: villageName,
    );
  }

  // Baseline fallback list for smooth experience
  static final List<DistrictModel> _fallbackDistricts = [
    const DistrictModel(id: 1, district: 'Pune', stateId: 1),
    const DistrictModel(id: 35, district: 'Thane', stateId: 1),
    const DistrictModel(id: 31, district: 'Mumbai Suburban', stateId: 1),
    const DistrictModel(id: 24, district: 'Nashik', stateId: 1),
    const DistrictModel(id: 8, district: 'Ahilyanagar', stateId: 1),
    const DistrictModel(id: 17, district: 'Akola', stateId: 1),
    const DistrictModel(id: 29, district: 'Nagpur', stateId: 1),
    const DistrictModel(id: 7, district: 'Solapur', stateId: 1),
    const DistrictModel(id: 9, district: 'Kolhapur', stateId: 1),
    const DistrictModel(id: 37, district: 'Palghar', stateId: 1),
  ];

  static List<TalukaModel> _fallbackTalukas(int districtId) {
    return [
      TalukaModel(id: 232, taluka: 'Haveli', districtId: districtId),
      TalukaModel(id: 233, taluka: 'Khed', districtId: districtId),
      TalukaModel(id: 234, taluka: 'Maval', districtId: districtId),
      TalukaModel(id: 235, taluka: 'Mulshi', districtId: districtId),
      TalukaModel(id: 236, taluka: 'Thane', districtId: districtId),
    ];
  }

  static List<VillageCityModel> _fallbackVillageCities(int districtId, int talukaId, bool isTown) {
    if (isTown) {
      return [
        VillageCityModel(id: 101, name: 'Wagholi', districtId: districtId, talukaId: talukaId, isTown: true),
        VillageCityModel(id: 102, name: 'Kharadi', districtId: districtId, talukaId: talukaId, isTown: true),
        VillageCityModel(id: 103, name: 'Alsangikar', districtId: districtId, talukaId: talukaId, isTown: true),
        VillageCityModel(id: 104, name: 'Vashind', districtId: districtId, talukaId: talukaId, isTown: true),
        VillageCityModel(id: 105, name: 'Kasauli', districtId: districtId, talukaId: talukaId, isTown: true),
        VillageCityModel(id: 106, name: 'Talegaon Dabhade', districtId: districtId, talukaId: talukaId, isTown: true),
      ];
    } else {
      return [
        VillageCityModel(id: 201, name: 'Pune City', districtId: districtId, talukaId: talukaId, isTown: false),
        VillageCityModel(id: 202, name: 'Pimpri-Chinchwad', districtId: districtId, talukaId: talukaId, isTown: false),
        VillageCityModel(id: 203, name: 'Thane City (M Corp.)', districtId: districtId, talukaId: talukaId, isTown: false),
        VillageCityModel(id: 204, name: 'Kalyan-Dombivli', districtId: districtId, talukaId: talukaId, isTown: false),
        VillageCityModel(id: 205, name: 'Navi Mumbai', districtId: districtId, talukaId: talukaId, isTown: false),
        VillageCityModel(id: 206, name: 'Akola (M Corp.)', districtId: districtId, talukaId: talukaId, isTown: false),
      ];
    }
  }
}
