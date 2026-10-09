import 'package:dio/dio.dart';
import '../../core/network/release_json.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/location_models.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

abstract class LocationRepository {
  Future<List<StateModel>> getStates();
  Future<List<DistrictModel>> getDistricts([int stateId = 1]);
  Future<List<TalukaModel>> getTalukas(int districtId);
  Future<List<VillageCityModel>> getVillageCities({
    required int districtId,
    required int talukaId,
    required bool isTown,
    int userId = 0,
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

  List<StateModel>? _cachedStates;
  final Map<int, List<DistrictModel>> _cachedDistricts = {};
  final Map<int, List<TalukaModel>> _cachedTalukas = {};
  final Map<String, List<VillageCityModel>> _cachedCensus = {};

  @override
  Future<List<StateModel>> getStates() async {
    if (_cachedStates != null && _cachedStates!.isNotEmpty) {
      return _cachedStates!;
    }

    try {
      final url = ApiEndpoints.getStatesUrl;
      final response = await _dio.get(url);
      final data = asResponseMap(response.data);

      if (data != null && data['responseData'] is List) {
        final list = (data['responseData'] as List)
            .map((item) => StateModel.fromJson(item as Map<String, dynamic>))
            .where((s) => s.state.trim().isNotEmpty)
            .toList();
        
        list.sort((a, b) => a.state.compareTo(b.state));
        _cachedStates = list;
        return _cachedStates!;
      }
    } catch (_) {
    }
    
    return [];
  }

  @override
  Future<List<DistrictModel>> getDistricts([int stateId = 1]) async {
    if (_cachedDistricts.containsKey(stateId) && _cachedDistricts[stateId]!.isNotEmpty) {
      return _cachedDistricts[stateId]!;
    }

    try {
      final url = ApiEndpoints.getDistrictsUrl(stateId);
      final response = await _dio.get(url);
      final data = asResponseMap(response.data);

      if (data != null && data['responseData'] is List) {
        final list = (data['responseData'] as List)
            .map((item) => DistrictModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .where((d) => d.district.trim().isNotEmpty)
            .toList();
        
        list.sort((a, b) => a.district.compareTo(b.district));
        _cachedDistricts[stateId] = list;
        return _cachedDistricts[stateId]!;
      }
    } catch (_) {
    }

    return [];
  }

  @override
  Future<List<TalukaModel>> getTalukas(int districtId) async {
    if (_cachedTalukas.containsKey(districtId)) {
      return _cachedTalukas[districtId]!;
    }

    try {
      final url = ApiEndpoints.getTalukasUrl(districtId);
      final response = await _dio.get(url);
      final data = asResponseMap(response.data);

      if (data != null && data['responseData'] is List) {
        final list = (data['responseData'] as List)
            .map((item) => TalukaModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .where((t) => t.taluka.trim().isNotEmpty)
            .toList();

        list.sort((a, b) => a.taluka.compareTo(b.taluka));
        _cachedTalukas[districtId] = list;
        return list;
      }
    } catch (_) {
    }

    return [];
  }

  @override
  Future<List<VillageCityModel>> getVillageCities({
    required int districtId,
    required int talukaId,
    required bool isTown,
    int userId = 0,
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
        userId: userId,
      );
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        final trimmed = data.trim();
        if (trimmed.startsWith('<?xml') || trimmed.startsWith('<string')) {
          final start = data.indexOf('{');
          final end = data.lastIndexOf('}');
          if (start != -1 && end != -1) {
            data = data.substring(start, end + 1);
          }
        }
      }

      final map = asResponseMap(data);
      if (map != null) {
        List<dynamic>? listData;
        if (map.containsKey('data1')) {
          listData = map['data1'] as List?;
        } else if (map['responseData'] is Map && (map['responseData'] as Map)['data'] is List) {
          listData = (map['responseData'] as Map)['data'] as List;
        }
        
        if (listData != null) {
          final list = listData
              .map((item) => VillageCityModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .where((v) => v.name.trim().isNotEmpty)
              .toList();

          list.sort((a, b) => a.name.compareTo(b.name));
          _cachedCensus[cacheKey] = list;
          return list;
        }
      }
    } catch (e) {
      // Return empty list instead of static data if API returns no data (e.g. 404)
    }

    return [];
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

}
