import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/organization.dart';
import '../data/repositories/organization_repository.dart';
import 'session_provider.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepositoryImpl();
});

class OperatingContextState {
  final Organization? organization;
  final Project? activeProject;
  final Package? activePackage;
  final List<Project> projects;
  final List<Package> packages;
  final List<dynamic> supervisors;
  final bool isLoading;

  const OperatingContextState({
    this.organization,
    this.activeProject,
    this.activePackage,
    this.projects = const [],
    this.packages = const [],
    this.supervisors = const [],
    this.isLoading = false,
  });

  OperatingContextState copyWith({
    Organization? organization,
    Project? activeProject,
    Package? activePackage,
    List<Project>? projects,
    List<Package>? packages,
    bool? isLoading,
  }) {
    return OperatingContextState(
      organization: organization ?? this.organization,
      activeProject: activeProject ?? this.activeProject,
      activePackage: activePackage ?? this.activePackage,
      projects: projects ?? this.projects,
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OperatingContextNotifier extends StateNotifier<OperatingContextState> {
  final OrganizationRepository _orgRepo;
  final Ref _ref;

  OperatingContextNotifier(this._orgRepo, this._ref) : super(const OperatingContextState(isLoading: true)) {
    _initScope();
  }

  Future<void> _initScope() async {
    final user = _ref.read(sessionProvider).currentUser;
    final orgId = user?.organizationId ?? 'org-001';

    try {
      final org = await _orgRepo.getOrganization(orgId);
      final projects = await _orgRepo.listProjects(orgId);
      final activeProj = projects.isNotEmpty ? projects.first : null;
      List<Package> packages = [];
      if (activeProj != null) {
        packages = await _orgRepo.listPackages(activeProj.id);
      }
      final activePkg = packages.isNotEmpty ? packages.first : null;

      state = OperatingContextState(
        organization: org,
        projects: projects,
        activeProject: activeProj,
        packages: packages,
        activePackage: activePkg,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectProject(Project project) async {
    state = state.copyWith(activeProject: project, isLoading: true);
    final pkgs = await _orgRepo.listPackages(project.id);
    state = state.copyWith(
      packages: pkgs,
      activePackage: pkgs.isNotEmpty ? pkgs.first : null,
      isLoading: false,
    );
  }

  void selectPackage(Package package) {
    state = state.copyWith(activePackage: package);
  }

  Future<void> refresh() => _initScope();
}

final operatingContextProvider = StateNotifierProvider<OperatingContextNotifier, OperatingContextState>((ref) {
  final orgRepo = ref.watch(organizationRepositoryProvider);
  return OperatingContextNotifier(orgRepo, ref);
});
