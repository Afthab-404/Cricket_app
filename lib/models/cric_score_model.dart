/// Model for /cricScore endpoint items (used for upcoming + live card display)
class CricScoreMatch {
  final String id;
  final String dateTimeGMT;
  final String matchType;
  final String status;
  final String ms; // "fixture" | "live" | "result"
  final String t1;
  final String t2;
  final String t1s; // score string from cricScore e.g. "187/4 (20)"
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

  factory CricScoreMatch.fromJson(Map<String, dynamic> j) => CricScoreMatch(
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

  bool get isLive    => ms == 'live';
  bool get isFixture => ms == 'fixture';
  bool get isResult  => ms == 'result';

  /// "CSK" from "Chennai Super Kings [CSK]"
  String get t1Short => _short(t1);
  String get t2Short => _short(t2);

  /// "Chennai Super Kings" from "Chennai Super Kings [CSK]"
  String get t1Name => _name(t1);
  String get t2Name => _name(t2);

  static String _short(String raw) {
    final m = RegExp(r'\[([^\]]+)\]').firstMatch(raw);
    if (m != null) return m.group(1)!;
    final t = raw.trim();
    return t.length >= 3 ? t.substring(0, 3).toUpperCase() : t.toUpperCase();
  }

  static String _name(String raw) =>
      raw.replaceAll(RegExp(r'\s*\[[^\]]+\]'), '').trim();
}

// ── Model for /currentMatches — richer live data ──────────────────────────────

class LiveMatch {
  final String id;
  final String name;
  final String matchType;
  final String status;
  final String venue;
  final String date;
  final String dateTimeGMT;
  final List<String> teams;
  final List<LiveTeamInfo> teamInfo;
  final List<LiveInnings> score;
  final bool matchStarted;
  final bool matchEnded;

  LiveMatch({
    required this.id,
    required this.name,
    required this.matchType,
    required this.status,
    required this.venue,
    required this.date,
    required this.dateTimeGMT,
    required this.teams,
    required this.teamInfo,
    required this.score,
    required this.matchStarted,
    required this.matchEnded,
  });

  bool get isLive => matchStarted && !matchEnded;

  factory LiveMatch.fromJson(Map<String, dynamic> j) => LiveMatch(
        id:           j['id']           as String? ?? '',
        name:         j['name']         as String? ?? '',
        matchType:    j['matchType']    as String? ?? '',
        status:       j['status']       as String? ?? '',
        venue:        j['venue']        as String? ?? '',
        date:         j['date']         as String? ?? '',
        dateTimeGMT:  j['dateTimeGMT']  as String? ?? '',
        teams:        List<String>.from(j['teams'] as List? ?? []),
        teamInfo: (j['teamInfo'] as List<dynamic>?)
                ?.map((e) => LiveTeamInfo.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        score: (j['score'] as List<dynamic>?)
                ?.map((e) => LiveInnings.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        matchStarted: j['matchStarted'] as bool? ?? false,
        matchEnded:   j['matchEnded']   as bool? ?? false,
      );

  String get t1Short => teamInfo.isNotEmpty
      ? teamInfo[0].shortname
      : (teams.isNotEmpty && teams[0].length >= 3
          ? teams[0].substring(0, 3).toUpperCase()
          : 'T1');

  String get t2Short => teamInfo.length > 1
      ? teamInfo[1].shortname
      : (teams.length > 1 && teams[1].length >= 3
          ? teams[1].substring(0, 3).toUpperCase()
          : 'T2');

  String get t1Name => teams.isNotEmpty ? teams[0] : 'Team 1';
  String get t2Name => teams.length > 1  ? teams[1] : 'Team 2';

  String get t1img => teamInfo.isNotEmpty      ? teamInfo[0].img : '';
  String get t2img => teamInfo.length > 1       ? teamInfo[1].img : '';

  /// Innings for team 1 (odd innings: 1, 3)
  List<LiveInnings> get t1Innings =>
      score.where((s) => s.inning == 1 || s.inning == 3).toList();

  /// Innings for team 2 (even innings: 2, 4)
  List<LiveInnings> get t2Innings =>
      score.where((s) => s.inning == 2 || s.inning == 4).toList();
}

class LiveTeamInfo {
  final String name;
  final String shortname;
  final String img;

  LiveTeamInfo({required this.name, required this.shortname, required this.img});

  factory LiveTeamInfo.fromJson(Map<String, dynamic> j) => LiveTeamInfo(
        name:      j['name']      as String? ?? '',
        shortname: j['shortname'] as String? ?? '',
        img:       j['img']       as String? ?? '',
      );
}

class LiveInnings {
  final String id;
  final int    inning;
  final int    r;
  final int    w;
  final double o;

  LiveInnings({
    required this.id,
    required this.inning,
    required this.r,
    required this.w,
    required this.o,
  });

  factory LiveInnings.fromJson(Map<String, dynamic> j) => LiveInnings(
        id:     j['id']     as String? ?? '',
        inning: j['inning'] as int?    ?? 1,
        r:      j['r']      as int?    ?? 0,
        w:      j['w']      as int?    ?? 0,
        o:      (j['o'] ?? 0.0).toDouble(),
      );

  /// e.g. "187/4 (18.2)"
  String get scoreStr => '$r/$w (${o.toStringAsFixed(1)})';
}