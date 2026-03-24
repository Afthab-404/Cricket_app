class ScorecardModel {
  final String id;
  final String name;
  final String matchType;
  final String status;
  final String venue;
  final String date;
  final List<String> teams;
  final List<TeamInfo> teamInfo;
  final List<ScorecardInnings> scorecard;
  final List<SeriesInfo> series;

  ScorecardModel({
    required this.id,
    required this.name,
    required this.matchType,
    required this.status,
    required this.venue,
    required this.date,
    required this.teams,
    required this.teamInfo,
    required this.scorecard,
    required this.series,
  });

  factory ScorecardModel.fromJson(Map<String, dynamic> json) {
    return ScorecardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      matchType: json['matchType'] ?? '',
      status: json['status'] ?? '',
      venue: json['venue'] ?? '',
      date: json['date'] ?? '',
      teams: List<String>.from(json['teams'] ?? []),
      teamInfo: (json['teamInfo'] as List<dynamic>?)
              ?.map((e) => TeamInfo.fromJson(e))
              .toList() ??
          [],
      scorecard: (json['scorecard'] as List<dynamic>?)
              ?.map((e) => ScorecardInnings.fromJson(e))
              .toList() ??
          [],
      series: (json['series'] as List<dynamic>?)
              ?.map((e) => SeriesInfo.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TeamInfo {
  final String name;
  final String shortname;
  final String img;

  TeamInfo({required this.name, required this.shortname, required this.img});

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      name: json['name'] ?? '',
      shortname: json['shortname'] ?? '',
      img: json['img'] ?? '',
    );
  }
}

class SeriesInfo {
  final String id;
  final String name;

  SeriesInfo({required this.id, required this.name});

  factory SeriesInfo.fromJson(Map<String, dynamic> json) {
    return SeriesInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class ScorecardInnings {
  final int inning;
  final String team;
  final InningsTotal total;
  final List<BatsmanScore> batsmen;
  final List<BowlerScore> bowlers;
  final List<FallOfWicket> fow;
  final List<ExtrasDetail> extras;

  ScorecardInnings({
    required this.inning,
    required this.team,
    required this.total,
    required this.batsmen,
    required this.bowlers,
    required this.fow,
    required this.extras,
  });

  factory ScorecardInnings.fromJson(Map<String, dynamic> json) {
    return ScorecardInnings(
      inning: json['inning'] ?? 1,
      team: json['team'] ?? '',
      total: InningsTotal.fromJson(json['total'] ?? {}),
      batsmen: (json['batsmen'] as List<dynamic>?)
              ?.map((e) => BatsmanScore.fromJson(e))
              .toList() ??
          [],
      bowlers: (json['bowlers'] as List<dynamic>?)
              ?.map((e) => BowlerScore.fromJson(e))
              .toList() ??
          [],
      fow: (json['fow'] as List<dynamic>?)
              ?.map((e) => FallOfWicket.fromJson(e))
              .toList() ??
          [],
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => ExtrasDetail.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InningsTotal {
  final int r;
  final int w;
  final double o;
  final int balls;
  final double rr;

  InningsTotal({
    required this.r,
    required this.w,
    required this.o,
    required this.balls,
    required this.rr,
  });

  factory InningsTotal.fromJson(Map<String, dynamic> json) {
    return InningsTotal(
      r: json['r'] ?? 0,
      w: json['w'] ?? 0,
      o: (json['o'] ?? 0.0).toDouble(),
      balls: json['balls'] ?? 0,
      rr: (json['rr'] ?? 0.0).toDouble(),
    );
  }
}

class BatsmanScore {
  final String id;
  final String name;
  final int r;
  final int b;
  final int fours;
  final int sixes;
  final double sr;
  final String dismissal;
  final bool isCurrentBatsman;

  BatsmanScore({
    required this.id,
    required this.name,
    required this.r,
    required this.b,
    required this.fours,
    required this.sixes,
    required this.sr,
    required this.dismissal,
    this.isCurrentBatsman = false,
  });

  factory BatsmanScore.fromJson(Map<String, dynamic> json) {
    return BatsmanScore(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      r: json['r'] ?? 0,
      b: json['b'] ?? 0,
      fours: json['4s'] ?? 0,
      sixes: json['6s'] ?? 0,
      sr: (json['sr'] ?? 0.0).toDouble(),
      dismissal: json['dismissal'] ?? '',
      isCurrentBatsman: json['dismissal'] == null || json['dismissal'] == '',
    );
  }
}

class BowlerScore {
  final String id;
  final String name;
  final double o;
  final int m;
  final int r;
  final int w;
  final double eco;
  final bool isCurrentBowler;

  BowlerScore({
    required this.id,
    required this.name,
    required this.o,
    required this.m,
    required this.r,
    required this.w,
    required this.eco,
    this.isCurrentBowler = false,
  });

  factory BowlerScore.fromJson(Map<String, dynamic> json) {
    return BowlerScore(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      o: (json['o'] ?? 0.0).toDouble(),
      m: json['m'] ?? 0,
      r: json['r'] ?? 0,
      w: json['w'] ?? 0,
      eco: (json['eco'] ?? 0.0).toDouble(),
      isCurrentBowler: false,
    );
  }
}

class FallOfWicket {
  final int num;
  final String batsman;
  final int r;
  final double o;

  FallOfWicket({
    required this.num,
    required this.batsman,
    required this.r,
    required this.o,
  });

  factory FallOfWicket.fromJson(Map<String, dynamic> json) {
    return FallOfWicket(
      num: json['num'] ?? 0,
      batsman: json['batsman'] ?? '',
      r: json['r'] ?? 0,
      o: (json['o'] ?? 0.0).toDouble(),
    );
  }
}

class ExtrasDetail {
  final String r;
  final String b;
  final String lb;
  final String wd;
  final String nb;
  final String p;
  final String total;

  ExtrasDetail({
    required this.r,
    required this.b,
    required this.lb,
    required this.wd,
    required this.nb,
    required this.p,
    required this.total,
  });

  factory ExtrasDetail.fromJson(Map<String, dynamic> json) {
    return ExtrasDetail(
      r: json['r']?.toString() ?? '0',
      b: json['b']?.toString() ?? '0',
      lb: json['lb']?.toString() ?? '0',
      wd: json['wd']?.toString() ?? '0',
      nb: json['nb']?.toString() ?? '0',
      p: json['p']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
    );
  }
}
