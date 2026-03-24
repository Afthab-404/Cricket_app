class MatchModel {
  final String id;
  final String name;
  final String matchType;
  final String status;
  final String venue;
  final String date;
  final String dateTimeGMT;
  final List<String> teams;
  final List<TeamInfo> teamInfo;
  final Score? score;
  final String? series;
  final bool fantasyEnabled;
  final bool bbbEnabled;
  final bool hasSquad;
  final bool matchStarted;
  final bool matchEnded;

  MatchModel({
    required this.id,
    required this.name,
    required this.matchType,
    required this.status,
    required this.venue,
    required this.date,
    required this.dateTimeGMT,
    required this.teams,
    required this.teamInfo,
    this.score,
    this.series,
    this.fantasyEnabled = false,
    this.bbbEnabled = false,
    this.hasSquad = false,
    this.matchStarted = false,
    this.matchEnded = false,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      matchType: json['matchType'] ?? '',
      status: json['status'] ?? '',
      venue: json['venue'] ?? '',
      date: json['date'] ?? '',
      dateTimeGMT: json['dateTimeGMT'] ?? '',
      teams: List<String>.from(json['teams'] ?? []),
      teamInfo: (json['teamInfo'] as List<dynamic>?)
              ?.map((e) => TeamInfo.fromJson(e))
              .toList() ??
          [],
      score: json['score'] != null
          ? Score.fromJsonList(json['score'] as List<dynamic>)
          : null,
      series: json['series'],
      fantasyEnabled: json['fantasyEnabled'] ?? false,
      bbbEnabled: json['bbbEnabled'] ?? false,
      hasSquad: json['hasSquad'] ?? false,
      matchStarted: json['matchStarted'] ?? false,
      matchEnded: json['matchEnded'] ?? false,
    );
  }

  bool get isLive => matchStarted && !matchEnded;
  bool get isUpcoming => !matchStarted && !matchEnded;
  bool get isCompleted => matchEnded;
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

class Score {
  final List<InningsScore> innings;

  Score({required this.innings});

  factory Score.fromJsonList(List<dynamic> json) {
    return Score(
      innings: json.map((e) => InningsScore.fromJson(e)).toList(),
    );
  }
}

class InningsScore {
  final String id;
  final int inning;
  final int r;
  final int w;
  final double o;

  InningsScore({
    required this.id,
    required this.inning,
    required this.r,
    required this.w,
    required this.o,
  });

  factory InningsScore.fromJson(Map<String, dynamic> json) {
    return InningsScore(
      id: json['id'] ?? '',
      inning: json['inning'] ?? 1,
      r: json['r'] ?? 0,
      w: json['w'] ?? 0,
      o: (json['o'] ?? 0.0).toDouble(),
    );
  }
}
