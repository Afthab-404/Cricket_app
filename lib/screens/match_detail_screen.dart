import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cric_score_model.dart';
import '../models/scorecard_model.dart';
import '../services/cricket_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/scorecard_widget.dart';

class MatchDetailScreen extends StatefulWidget {
  final LiveMatch match;
  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScorecardModel? _scorecard;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScorecard();
    if (widget.match.isLive) {
      _refreshTimer = Timer.periodic(
          const Duration(seconds: 60), (_) => _loadScorecard(force: true));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadScorecard({bool force = false}) async {
    if (mounted) setState(() => _isLoading = true);
    final sc = await CricketApiService.getMatchScorecard(
        widget.match.id, forceRefresh: force);
    if (mounted) setState(() { _scorecard = sc; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.matchTypeColor(widget.match.matchType);
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(children: [
        _buildHeader(typeColor),
        _buildScoreHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildScorecardTab(), _buildInfoTab()],
          ),
        ),
      ]),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(Color typeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [typeColor.withOpacity(0.3), AppTheme.darkBg],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppTheme.textPrimary, size: 18),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.match.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (widget.match.venue.isNotEmpty)
                    Text(widget.match.venue,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (widget.match.matchType.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: typeColor.withOpacity(0.5)),
                ),
                child: Text(widget.match.matchType.toUpperCase(),
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _loadScorecard(force: true),
              icon: const Icon(Icons.refresh,
                  color: AppTheme.textSecondary, size: 20),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Score header ───────────────────────────────────────────────────────────

  Widget _buildScoreHeader() {
    final match = widget.match;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.liveRed.withOpacity(0.4)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: _teamBlock(
              match.t1Short, match.t1Innings, true)),
          _livePulse(),
          Expanded(child: _teamBlock(
              match.t2Short, match.t2Innings, false)),
        ]),
        const SizedBox(height: 12),
        const Divider(color: AppTheme.dividerColor, height: 1),
        const SizedBox(height: 10),
        Text(match.status,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.goldYellow,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        // Current batsmen/bowler from scorecard
        if (_scorecard != null && _scorecard!.scorecard.isNotEmpty) ...[
          const SizedBox(height: 12),
          _currentPlayersRow(),
        ],
      ]),
    );
  }

  Widget _teamBlock(
      String shortName, List<LiveInnings> innings, bool isLeft) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(shortName,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 6),
        if (innings.isEmpty)
          const Text('Yet to bat',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))
        else
          ...innings.map((inn) => Text(inn.scoreStr,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800))),
      ],
    );
  }

  Widget _livePulse() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (_, v, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.liveRed.withOpacity(0.8 * v),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('● LIVE',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      ),
      onEnd: () => setState(() {}),
    );
  }

  Widget _currentPlayersRow() {
    final lastInnings = _scorecard!.scorecard.lastOrNull;
    if (lastInnings == null) return const SizedBox();

    final batsmen = lastInnings.batsmen
        .where((b) => b.isCurrentBatsman)
        .take(2)
        .toList();
    final bowler = lastInnings.bowlers
            .where((b) => b.isCurrentBowler)
            .firstOrNull ??
        (lastInnings.bowlers.isNotEmpty ? lastInnings.bowlers.last : null);
    final displayBatsmen =
        batsmen.isNotEmpty ? batsmen : lastInnings.batsmen.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Icon(Icons.sports_cricket,
                    color: AppTheme.accentGreen, size: 12),
                SizedBox(width: 4),
                Text('BATTING',
                    style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              ...displayBatsmen.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(children: [
                      Expanded(
                        child: Text(b.name.split(' ').last,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('${b.r}(${b.b})',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ]),
                  )),
            ],
          ),
        ),
        Container(
            width: 1, height: 60,
            color: AppTheme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: const [
                Icon(Icons.sports_baseball, color: Colors.orange, size: 12),
                SizedBox(width: 4),
                Text('BOWLING',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              if (bowler != null) ...[
                Text(bowler.name.split(' ').last,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('${bowler.o}-${bowler.m}-${bowler.r}-${bowler.w}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      height: 44,
      decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color.fromARGB(255, 61, 196, 70),
            Color.fromARGB(255, 89, 225, 94),
          ]),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [Tab(text: 'SCORECARD'), Tab(text: 'INFO')],
      ),
    );
  }

  // ── Scorecard tab ──────────────────────────────────────────────────────────

  Widget _buildScorecardTab() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen));
    }
    if (_scorecard == null || _scorecard!.scorecard.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.sports_cricket,
              color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 16),
          const Text('Scorecard not available yet',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _loadScorecard(force: true),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen.withOpacity(0.2),
              foregroundColor: AppTheme.accentGreen,
              elevation: 0,
            ),
          ),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _scorecard!.scorecard.length,
      itemBuilder: (_, i) {
        final innings = _scorecard!.scorecard[i];
        final isLast  = i == _scorecard!.scorecard.length - 1;
        return Column(children: [
          ScorecardWidget(
              innings: innings,
              isCurrentInnings: widget.match.isLive && isLast),
          if (i < _scorecard!.scorecard.length - 1) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.dividerColor, thickness: 2),
            const SizedBox(height: 16),
          ],
        ]);
      },
    );
  }

  // ── Info tab ───────────────────────────────────────────────────────────────

  Widget _buildInfoTab() {
    final match = widget.match;
    String localTime = '';
    try {
      final dt = DateTime.parse(match.dateTimeGMT).toLocal();
      localTime =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { localTime = match.dateTimeGMT; }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _infoCard('Match Details', [
          _infoRow(Icons.sports_cricket, 'Format',
              match.matchType.isEmpty ? 'N/A' : match.matchType.toUpperCase()),
          _infoRow(Icons.stadium, 'Venue',
              match.venue.isEmpty ? 'N/A' : match.venue),
          _infoRow(Icons.access_time, 'Date & Time (local)', localTime),
          _infoRow(Icons.info_outline, 'Status', match.status),
        ]),
        const SizedBox(height: 16),
        _infoCard('Teams', [
          _infoRow(Icons.people_outline, 'Team 1', match.t1Name),
          _infoRow(Icons.people_outline, 'Team 2', match.t2Name),
        ]),
        if (_scorecard != null && _scorecard!.series.isNotEmpty) ...[
          const SizedBox(height: 16),
          _infoCard('Series', [
            ..._scorecard!.series.map((s) =>
                _infoRow(Icons.emoji_events_outlined, 'Series', s.name)),
          ]),
        ],
      ],
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const Divider(color: AppTheme.dividerColor, height: 1),
        const SizedBox(height: 10),
        ...rows,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppTheme.accentGreen, size: 16),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13))),
      ]),
    );
  }
}