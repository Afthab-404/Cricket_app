/// Model for the /cricScore endpoint.
/// Each item has an `ms` field: "fixture" | "live" | "result"
class CricScoreMatch {
  final String id;
  final String dateTimeGMT;
  final String matchType;
  final String status;
  final String ms; // "fixture" | "live" | "result"
  final String t1; // e.g. "Chennai Super Kings [CSK]"
  final String t2;
  final String t1s; // score string e.g. "187/4 (20)"
  final String t2s;
  final String t1img;
  final String t2img;
  final String series;

  CricScoreMatch({
    required this.id,
    required this.dateTimeGMT,
    required this.matchType,
    required this.status,
    required this.ms,
    required this.t1,
    required this.t2,
    required this.t1s,
    required this.t2s,
    required this.t1img,
    required this.t2img,
    required this.series,
  });

  factory CricScoreMatch.fromJson(Map<String, dynamic> j) {
    return CricScoreMatch(
      id:          j['id']          as String? ?? '',
      dateTimeGMT: j['dateTimeGMT'] as String? ?? '',
      matchType:   j['matchType']   as String? ?? '',
      status:      j['status']      as String? ?? '',
      ms:          j['ms']          as String? ?? '',
      t1:          j['t1']          as String? ?? '',
      t2:          j['t2']          as String? ?? '',
      t1s:         j['t1s']         as String? ?? '',
      t2s:         j['t2s']         as String? ?? '',
      t1img:       j['t1img']       as String? ?? '',
      t2img:       j['t2img']       as String? ?? '',
      series:      j['series']      as String? ?? '',
    );
  }

  // ── Derived helpers ────────────────────────────────────────────────────────

  bool get isLive     => ms == 'live';
  bool get isFixture  => ms == 'fixture';
  bool get isResult   => ms == 'result';

  /// Short team name extracted from e.g. "Chennai Super Kings [CSK]" → "CSK"
  /// Falls back to first 3 chars of full name if no bracket found.
  String get t1Short => _shortName(t1);
  String get t2Short => _shortName(t2);

  /// Full team name without the bracket part.
  String get t1Name => _fullName(t1);
  String get t2Name => _fullName(t2);

  static String _shortName(String raw) {
    final match = RegExp(r'\[([^\]]+)\]').firstMatch(raw);
    if (match != null) return match.group(1)!;
    final trimmed = raw.trim();
    return trimmed.length >= 3 ? trimmed.substring(0, 3).toUpperCase() : trimmed.toUpperCase();
  }

  static String _fullName(String raw) {
    return raw.replaceAll(RegExp(r'\s*\[[^\]]+\]'), '').trim();
  }
}