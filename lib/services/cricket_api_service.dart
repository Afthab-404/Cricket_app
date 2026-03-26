import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/cric_score_model.dart';
import '../models/scorecard_model.dart' as sc;

class CricketApiService {
  static const _apiKey          = 'a21f29da-cca3-45c2-b8db-6fcccef64f50';
  static const _baseUrl         = 'https://api.cricapi.com/v1';

  // Cache durations
  static const _liveCacheDuration     = Duration(minutes: 2);
  static const _upcomingCacheDuration = Duration(minutes: 15);
  static const _scorecardCacheDuration = Duration(seconds: 60);

  // Live matches cache (from /currentMatches)
  static List<LiveMatch>? _liveCache;
  static DateTime?         _liveCachedAt;
  static bool              _fetchingLive = false;

  // Upcoming cache (from /cricScore)
  static List<CricScoreMatch>? _upcomingCache;
  static DateTime?              _upcomingCachedAt;
  static bool                   _fetchingUpcoming = false;

  // Per-match scorecard cache
  static final Map<String, sc.ScorecardModel> _scorecardCache    = {};
  static final Map<String, DateTime>           _scorecardCachedAt = {};

  static void _log(String msg) => developer.log(msg, name: 'CricAPI');

  // ── Live matches — /currentMatches gives r/w/o per innings ───────────────

  static Future<List<LiveMatch>> getLiveMatches({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _liveCache != null &&
        _liveCachedAt != null &&
        DateTime.now().difference(_liveCachedAt!) < _liveCacheDuration) {
      _log('live cache hit (${_liveCache!.length})');
      return _liveCache!;
    }
    if (_fetchingLive) return _liveCache ?? [];

    _fetchingLive = true;
    try {
      final url = '$_baseUrl/currentMatches?apikey=$_apiKey&offset=0';
      _log('GET $url');
      final res = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _log('HTTP ${res.statusCode}');
      if (res.statusCode != 200) return _liveCache ?? [];

      final body   = json.decode(res.body) as Map<String, dynamic>;
      final status = body['status'] as String? ?? '';
      final info   = body['info']   as Map<String, dynamic>?;
      _log('status=$status hits=${info?['hitsToday']}/${info?['hitsLimit']}');
      if (status != 'success') return _liveCache ?? [];

      final raw = body['data'] as List<dynamic>? ?? [];
      final all = raw.map((e) =>
          LiveMatch.fromJson(e as Map<String, dynamic>)).toList();

      final live = all.where((m) => m.isLive).toList();
      _log('currentMatches: ${all.length} total, ${live.length} live');
      for (final m in live) {
        _log('  LIVE: ${m.name} — t1innings=${m.t1Innings.length} t2innings=${m.t2Innings.length}');
        for (final s in m.score) {
          _log('    inning=${s.inning} ${s.scoreStr}');
        }
      }

      _liveCache    = live;
      _liveCachedAt = DateTime.now();
      return live;
    } catch (e) {
      _log('getLiveMatches exception: $e');
      return _liveCache ?? [];
    } finally {
      _fetchingLive = false;
    }
  }

  // ── Upcoming matches — /cricScore is cheapest source ─────────────────────

  static Future<List<CricScoreMatch>> getUpcomingMatches({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _upcomingCache != null &&
        _upcomingCachedAt != null &&
        DateTime.now().difference(_upcomingCachedAt!) < _upcomingCacheDuration) {
      _log('upcoming cache hit (${_upcomingCache!.length})');
      return _upcomingCache!;
    }
    if (_fetchingUpcoming) return _upcomingCache ?? [];

    _fetchingUpcoming = true;
    try {
      final url = '$_baseUrl/cricScore?apikey=$_apiKey';
      _log('GET $url');
      final res = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _log('HTTP ${res.statusCode}');
      if (res.statusCode != 200) return _upcomingCache ?? [];

      final body   = json.decode(res.body) as Map<String, dynamic>;
      final status = body['status'] as String? ?? '';
      if (status != 'success') return _upcomingCache ?? [];

      final raw = body['data'] as List<dynamic>? ?? [];
      final all = raw.map((e) =>
          CricScoreMatch.fromJson(e as Map<String, dynamic>)).toList();

      final upcoming = all.where((x) => x.ms == 'fixture').toList()
        ..sort((a, b) {
          try {
            return DateTime.parse(a.dateTimeGMT)
                .compareTo(DateTime.parse(b.dateTimeGMT));
          } catch (_) { return 0; }
        });

      _log('cricScore: ${upcoming.length} upcoming fixtures');
      _upcomingCache    = upcoming;
      _upcomingCachedAt = DateTime.now();
      return upcoming;
    } catch (e) {
      _log('getUpcomingMatches exception: $e');
      return _upcomingCache ?? [];
    } finally {
      _fetchingUpcoming = false;
    }
  }

  // ── Scorecard (detail screen only — costs 1 credit per call) ─────────────

  static Future<sc.ScorecardModel?> getMatchScorecard(
    String matchId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached   = _scorecardCache[matchId];
      final cachedAt = _scorecardCachedAt[matchId];
      if (cached != null &&
          cachedAt != null &&
          DateTime.now().difference(cachedAt) < _scorecardCacheDuration) {
        _log('scorecard cache hit: $matchId');
        return cached;
      }
    }
    try {
      final url = '$_baseUrl/match_scorecard?apikey=$_apiKey&id=$matchId';
      _log('scorecard GET $url');
      final res = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _log('scorecard HTTP ${res.statusCode}');
      if (res.statusCode != 200) return _scorecardCache[matchId];

      final body = json.decode(res.body) as Map<String, dynamic>;
      if (body['status'] != 'success') {
        _log('scorecard non-success: ${body['reason'] ?? body['message']}');
        return _scorecardCache[matchId];
      }

      final model = sc.ScorecardModel.fromJson(
          body['data'] as Map<String, dynamic>);
      _scorecardCache[matchId]    = model;
      _scorecardCachedAt[matchId] = DateTime.now();
      _log('scorecard OK: $matchId — ${model.scorecard.length} innings');
      return model;
    } catch (e) {
      _log('scorecard exception: $e');
      return _scorecardCache[matchId];
    }
  }

  static void invalidateCache() {
    _liveCachedAt     = null;
    _upcomingCachedAt = null;
    _log('all caches invalidated');
  }
}