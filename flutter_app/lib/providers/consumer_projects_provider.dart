import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/consumer_project_repository.dart';
import '../domain/consumer_project_models.dart';
import 'session_provider.dart';

class ConsumerProjectsState {
  final List<ConsumerProjectItem> projects;
  final bool isLoading;
  final String? error;

  const ConsumerProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ConsumerProjectsState copyWith({
    List<ConsumerProjectItem>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ConsumerProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConsumerProjectsNotifier extends StateNotifier<ConsumerProjectsState> {
  final ConsumerProjectRepository _repository;
  final Ref _ref;

  ConsumerProjectsNotifier(this._repository, this._ref)
      : super(const ConsumerProjectsState(isLoading: true)) {
    loadProjects();
  }

  Future<void> loadProjects({String search = ''}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(sessionProvider).currentUser;
      final userId = user?.id != null ? int.tryParse(user!.id) ?? 44434 : 44434;

      final response = await _repository.getProjectDetails(
        userId: userId,
        search: search,
      );

      if (response.isSuccess) {
        state = ConsumerProjectsState(
          projects: response.projects,
          isLoading: false,
        );
      } else {
        state = ConsumerProjectsState(
          projects: response.projects,
          isLoading: false,
          error: response.statusMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadProjects();
}

final consumerProjectsProvider =
    StateNotifierProvider<ConsumerProjectsNotifier, ConsumerProjectsState>((ref) {
  final repo = ref.watch(consumerProjectRepositoryProvider);
  return ConsumerProjectsNotifier(repo, ref);
});
