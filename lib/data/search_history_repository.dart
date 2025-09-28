// lib/data/search_history_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
class SearchHistoryRepository {
  static const _teamKey  = 'recent_search_teams';
  static const _userKey  = 'recent_search_users';

  Future<List<String>> loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_teamKey) ?? [];
  }

  Future<void> addTeam(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_teamKey) ?? [];
    list.remove(query);
    list.insert(0, query);
    await prefs.setStringList(_teamKey, list);
  }

  Future<void> clearTeams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_teamKey);
  }
  Future<void> saveTeams(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_teamKey, list);
  }

  // 개인 검색 기록
  Future<List<String>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userKey) ?? [];
  }

  Future<void> addUser(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_userKey) ?? [];
    list.remove(query);
    list.insert(0, query);
    await prefs.setStringList(_userKey, list);
  }

  Future<void> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> saveUsers(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_teamKey, list);
  }
}
