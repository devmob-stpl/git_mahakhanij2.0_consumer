import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/temporary_excavation.dart';
import '../data/repositories/excavation_repository.dart';

final excavationRepositoryProvider = Provider<ExcavationRepository>((ref) {
  return ExcavationRepositoryImpl();
});

enum ExcavationFilterTab { all, drafts, actionRequired }

class ExcavationState {
  final List<TemporaryExcavationApplication> applications;
  final ExcavationFilterTab activeTab;
  final TemporaryExcavationStatus? selectedStageFilter;
  final String searchQuery;
  final bool isLoading;

  const ExcavationState({
    this.applications = const [],
    this.activeTab = ExcavationFilterTab.all,
    this.selectedStageFilter,
    this.searchQuery = '',
    this.isLoading = false,
  });

  // 4 Stage Counts
  int get pendingCount => applications.where((a) =>
      a.status == TemporaryExcavationStatus.underReview ||
      a.status == TemporaryExcavationStatus.queryRaised).length;

  int get paymentDueCount => applications.where((a) =>
      a.status == TemporaryExcavationStatus.demandNoteIssued).length;

  int get permitReadyCount => applications.where((a) =>
      a.status == TemporaryExcavationStatus.orderIssued).length;

  int get rejectedCount => applications.where((a) =>
      a.status == TemporaryExcavationStatus.rejected).length;

  // Filter Pill Counts
  int get allCount => applications.where((a) => !a.isDraft).length;
  int get draftsCount => applications.where((a) => a.isDraft).length;
  int get actionRequiredCount => applications.where((a) =>
      a.status == TemporaryExcavationStatus.demandNoteIssued ||
      a.status == TemporaryExcavationStatus.queryRaised ||
      a.status == TemporaryExcavationStatus.rejected).length;

  List<TemporaryExcavationApplication> get filteredApplications {
    var list = applications;

    // Search query filter
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((a) =>
          a.applicationNumber.toLowerCase().contains(q) ||
          a.mineralName.toLowerCase().contains(q) ||
          a.village.toLowerCase().contains(q) ||
          a.surveyNumber.toLowerCase().contains(q)).toList();
    }

    // Tab filter
    switch (activeTab) {
      case ExcavationFilterTab.drafts:
        return list.where((a) => a.isDraft).toList();
      case ExcavationFilterTab.actionRequired:
        list = list.where((a) =>
            a.status == TemporaryExcavationStatus.demandNoteIssued ||
            a.status == TemporaryExcavationStatus.queryRaised ||
            a.status == TemporaryExcavationStatus.rejected).toList();
        break;
      case ExcavationFilterTab.all:
        list = list.where((a) => !a.isDraft).toList();
        break;
    }

    // Secondary Stage Card Filter
    if (selectedStageFilter != null) {
      if (selectedStageFilter == TemporaryExcavationStatus.underReview) {
        list = list.where((a) =>
            a.status == TemporaryExcavationStatus.underReview ||
            a.status == TemporaryExcavationStatus.queryRaised).toList();
      } else {
        list = list.where((a) => a.status == selectedStageFilter).toList();
      }
    }

    return list;
  }

  ExcavationState copyWith({
    List<TemporaryExcavationApplication>? applications,
    ExcavationFilterTab? activeTab,
    TemporaryExcavationStatus? selectedStageFilter,
    bool clearStageFilter = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ExcavationState(
      applications: applications ?? this.applications,
      activeTab: activeTab ?? this.activeTab,
      selectedStageFilter: clearStageFilter ? null : (selectedStageFilter ?? this.selectedStageFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ExcavationNotifier extends StateNotifier<ExcavationState> {
  final ExcavationRepository _repo;

  ExcavationNotifier(this._repo) : super(const ExcavationState(isLoading: true)) {
    loadApplications('org-001');
  }

  Future<void> loadApplications(String orgId) async {
    state = state.copyWith(isLoading: true);
    final apps = await _repo.listApplications(orgId);
    state = state.copyWith(applications: apps, isLoading: false);
  }

  void setFilterTab(ExcavationFilterTab tab) {
    if (state.activeTab == tab) {
      state = state.copyWith(activeTab: ExcavationFilterTab.all, clearStageFilter: true);
    } else {
      state = state.copyWith(activeTab: tab, clearStageFilter: true);
    }
  }

  void toggleStageFilter(TemporaryExcavationStatus stage) {
    if (state.selectedStageFilter == stage) {
      state = state.copyWith(clearStageFilter: true);
    } else {
      state = state.copyWith(
        selectedStageFilter: stage,
        activeTab: ExcavationFilterTab.all,
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> deleteDraft(String id, String orgId) async {
    await _repo.deleteDraft(id);
    await loadApplications(orgId);
  }
}

final excavationProvider = StateNotifierProvider<ExcavationNotifier, ExcavationState>((ref) {
  final repo = ref.watch(excavationRepositoryProvider);
  return ExcavationNotifier(repo);
});
