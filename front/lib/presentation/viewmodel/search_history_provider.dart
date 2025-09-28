// lib/viewmodel/search_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/data/search_history_repository.dart';

// 팀 기록 전용
final teamHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>(
      (ref) => SearchHistoryNotifier(SearchHistoryRepository(), isTeam: true),
);

// 개인 기록 전용
final userHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>(
      (ref) => SearchHistoryNotifier(SearchHistoryRepository(), isTeam: false),
);

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final SearchHistoryRepository _repo;
  final bool isTeam;

  SearchHistoryNotifier(this._repo, {required this.isTeam}) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = isTeam ? await _repo.loadTeams() : await _repo.loadUsers();
  }

  Future<void> add(String query) async {
    if (isTeam) {
      await _repo.addTeam(query);
    } else {
      await _repo.addUser(query);
    }
    state = isTeam ? await _repo.loadTeams() : await _repo.loadUsers();
  }

  Future<void> remove(String query) async {
    final newList = state.where((item) => item != query).toList();
    await _repo.saveTeams(newList);
    state = newList;
  }

  Future<void> clear() async {
    if (isTeam) {
      await _repo.clearTeams();
    } else {
      await _repo.clearUsers();
    }
    state = [];
  }
}
