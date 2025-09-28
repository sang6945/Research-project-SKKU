// lib/utils/stat_selector.dart

List<String> selectMainStatsAsText({
  required String selectedStat,
  required String position,
  required Map<String, dynamic> stats,
}) {
  // 포지션별 주요 스탯
  final Map<String, List<String>> positionStats = {
    'FW': ['sho', 'drv'],
    'MF': ['dec', 'dri'],
    'DF': ['tac', 'bld'],
  };

  // 공통 스탯
  final List<String> commonStats = ['pac', 'pas', 'spd'];

  // 선택된 스탯 키들 순서대로 구성
  final List<String> statKeys = [
    ...?positionStats[position.toUpperCase()],
    selectedStat.toLowerCase(),
    ...commonStats,
  ];

  // "STAT: 숫자" 형식의 리스트로 반환
  return statKeys.map((key) {
    final upperKey = key.toUpperCase();
    final value = stats[key] ?? 0;
    return '$upperKey: $value';
  }).toList();
}
