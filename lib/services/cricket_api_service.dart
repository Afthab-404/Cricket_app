import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/cric_score_model.dart';
import '../models/scorecard_model.dart' as sc;

class CricketApiService {
  static const _apiKey = 'a21f29da-cca3-45c2-b8db-6fcccef64f50';
  static const _scoreUrl = 'https://api.cricapi.com/v1/cricScore?apikey=$_apiKey';
  static const _scorecardUrl = 'https://api.cricapi.com/v1/match_scorecard?apikey=$_apiKey';

  static const _cacheDuration = Duration(minutes: 2);
  static List<CricScoreMatch>? _cache;
  static DateTime? _cachedAt;
  static bool _fetching = false;

  static void _log(String msg) => developer.log(msg, name: 'CricAPI');

  // ── Core fetch — ONE call covers everything ───────────────────────────────

  static Future<List<CricScoreMatch>> _all({bool force = false}) async {
    // Return cache if still fresh
    if (!force && _cache != null && _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheDuration) {
      _log('cache hit — ${_cache!.length} matches');
      return _cache!;
    }

    // Prevent concurrent fetches
    if (_fetching) {
      _log('already fetching, returning cache');
      return _cache ?? [];
    }

    _fetching = true;
    try {
      _log('GET $_scoreUrl');
      final res = await http
          .get(Uri.parse(_scoreUrl))
          .timeout(const Duration(seconds: 15));

      _log('HTTP ${res.statusCode}  body_len=${res.body.length}');

      if (res.statusCode != 200) {
        _log('non-200, keeping cache');
        return _cache ?? [];
      }

      final body   = json.decode(res.body) as Map<String, dynamic>;
      final status = body['status'] as String? ?? '';
      final info   = body['info']   as Map<String, dynamic>?;
      _log('status=$status  hitsToday=${info?['hitsToday']}/${info?['hitsLimit']}');

      if (status != 'success') {
        _log('API failure: ${body['reason'] ?? body['message'] ?? 'unknown'}');
        return _cache ?? [];
      }

      final raw     = body['data'] as List<dynamic>? ?? [];
      final matches = raw.map((e) =>
          CricScoreMatch.fromJson(e as Map<String, dynamic>)).toList();

      final live    = matches.where((x) => x.ms == 'live').length;
      final fixture = matches.where((x) => x.ms == 'fixture').length;
      final result  = matches.where((x) => x.ms == 'result').length;
      _log('parsed ${matches.length} — live=$live fixture=$fixture result=$result');

      _cache    = matches;
      _cachedAt = DateTime.now();
      return matches;
    } catch (e, st) {
      _log('exception: $e\n$st');
      return _cache ?? [];   // never throw — callers must not set error state from this
    } finally {
      _fetching = false;
    }
  }

  // ── Public methods ────────────────────────────────────────────────────────

  static Future<List<CricScoreMatch>> getLiveMatches({bool forceRefresh = false}) async {
    final all = await _all(force: forceRefresh);
    final live = all.where((x) => x.ms == 'live').toList();
    _log('getLiveMatches → ${live.length}');
    return live;
  }

  static Future<List<CricScoreMatch>> getUpcomingMatches({bool forceRefresh = false}) async {
    final all = await _all(force: forceRefresh);
    final upcoming = all.where((x) => x.ms == 'fixture').toList();

    // Sort soonest first
    upcoming.sort((a, b) {
      try {
        return DateTime.parse(a.dateTimeGMT).compareTo(DateTime.parse(b.dateTimeGMT));
      } catch (_) { return 0; }
    });

    _log('getUpcomingMatches → ${upcoming.length}');
    return upcoming;
  }

  static Future<sc.ScorecardModel?> getMatchScorecard(String matchId) async {
    try {
      final url = '$_scorecardUrl&id=$matchId';
      _log('scorecard GET $url');
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          return sc.ScorecardModel.fromJson(body['data'] as Map<String, dynamic>);
        }
        _log('scorecard non-success: ${body['reason'] ?? body['message']}');
      }
      return null;
    } catch (e) {
      _log('scorecard exception: $e');
      return null;
    }
  }

  static void invalidateCache() {
    _cachedAt = null;
    _log('cache invalidated');
  }
}