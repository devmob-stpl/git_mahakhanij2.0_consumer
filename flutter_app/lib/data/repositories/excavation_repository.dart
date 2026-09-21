import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/temporary_excavation.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

abstract class ExcavationRepository {
  Future<List<TemporaryExcavationApplication>> listApplications(String orgId);
  Future<TemporaryExcavationApplication?> getById(String id);
  Future<TemporaryExcavationApplication> saveDraft(TemporaryExcavationApplication app);
  Future<bool> deleteDraft(String id);
  Future<TemporaryExcavationApplication> submitApplication(TemporaryExcavationApplication app);
  Future<TemporaryExcavationApplication?> getCachedDraft(String orgId);
}

class ExcavationRepositoryImpl implements ExcavationRepository {
  final MockDb _db = MockDb();

  static String _draftStorageKey(String orgId) => 'mahakhanij_temp_excavation_draft_$orgId';

  @override
  Future<List<TemporaryExcavationApplication>> listApplications(String orgId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.excavationApplications.where((a) => a.organizationId == orgId).toList();
  }

  @override
  Future<TemporaryExcavationApplication?> getById(String id) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      return _db.excavationApplications.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TemporaryExcavationApplication> saveDraft(TemporaryExcavationApplication app) async {
    // 1. Update in-memory db
    final existingIndex = _db.excavationApplications.indexWhere((a) => a.id == app.id);
    if (existingIndex >= 0) {
      _db.excavationApplications[existingIndex] = app;
    } else {
      _db.excavationApplications.insert(0, app);
    }

    // 2. Persist to SharedPreferences for offline resume memory
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftStorageKey(app.organizationId), jsonEncode(app.toJson()));
    } catch (_) {}

    return app;
  }

  @override
  Future<bool> deleteDraft(String id) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    final index = _db.excavationApplications.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final orgId = _db.excavationApplications[index].organizationId;
      _db.excavationApplications.removeAt(index);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_draftStorageKey(orgId));
      } catch (_) {}
      return true;
    }
    return false;
  }

  @override
  Future<TemporaryExcavationApplication> submitApplication(TemporaryExcavationApplication app) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    final submitted = TemporaryExcavationApplication(
      id: app.id.startsWith('draft') ? 'exc-${DateTime.now().millisecondsSinceEpoch}' : app.id,
      applicationNumber: 'TE-2024-${(1000 + _db.excavationApplications.length).toString()}',
      organizationId: app.organizationId,
      projectId: app.projectId,
      packageId: app.packageId,
      applicant: app.applicant,
      mineralId: app.mineralId,
      mineralName: app.mineralName,
      estimatedQuantity: app.estimatedQuantity,
      excavationMethod: app.excavationMethod,
      purpose: app.purpose,
      siteAddress: app.siteAddress,
      siteGeo: app.siteGeo,
      village: app.village,
      surveyNumber: app.surveyNumber,
      subDivisionNumber: app.subDivisionNumber,
      landType: app.landType,
      areaInSqm: app.areaInSqm,
      depthInMetres: app.depthInMetres,
      fromDate: app.fromDate,
      toDate: app.toDate,
      applicationFee: app.applicationFee,
      status: TemporaryExcavationStatus.underReview,
      submittedAt: DateTime.now().toIso8601String(),
      statusUpdatedAt: DateTime.now().toIso8601String(),
      documents: app.documents,
    );

    // Remove old draft
    _db.excavationApplications.removeWhere((a) => a.id == app.id);
    _db.excavationApplications.insert(0, submitted);

    // Clear saved draft cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftStorageKey(app.organizationId));
    } catch (_) {}

    return submitted;
  }

  @override
  Future<TemporaryExcavationApplication?> getCachedDraft(String orgId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_draftStorageKey(orgId));
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return TemporaryExcavationApplication.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}
