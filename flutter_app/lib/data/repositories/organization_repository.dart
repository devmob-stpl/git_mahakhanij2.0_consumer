import '../../domain/organization.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

abstract class OrganizationRepository {
  Future<Organization?> getOrganization(String id);
  Future<List<Project>> listProjects(String orgId);
  Future<Project> createProject(Project project);
  Future<List<Package>> listPackages(String projectId);
  Future<Package> createPackage(Package package);
  Future<List<SupervisorInfo>> listSupervisors();
  Future<SupervisorInfo> registerSupervisor(SupervisorInfo supervisor);
}

class OrganizationRepositoryImpl implements OrganizationRepository {
  final MockDb _db = MockDb();

  @override
  Future<Organization?> getOrganization(String id) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      return _db.organizations.firstWhere((o) => o.id == id);
    } catch (_) {
      return _db.organizations.firstOrNull;
    }
  }

  @override
  Future<List<Project>> listProjects(String orgId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.projects.where((p) => p.organizationId == orgId).toList();
  }

  @override
  Future<Project> createProject(Project project) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    _db.projects.insert(0, project);
    return project;
  }

  @override
  Future<List<Package>> listPackages(String projectId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.packages.where((p) => p.projectId == projectId).toList();
  }

  @override
  Future<Package> createPackage(Package package) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    _db.packages.insert(0, package);
    return package;
  }

  @override
  Future<List<SupervisorInfo>> listSupervisors() async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.supervisors;
  }

  @override
  Future<SupervisorInfo> registerSupervisor(SupervisorInfo supervisor) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    _db.supervisors.insert(0, supervisor);
    return supervisor;
  }
}
