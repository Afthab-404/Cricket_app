import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cric_score_model.dart';
import '../models/scorecard_model.dart';
import '../services/cricket_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/scorecard_widget.dart';

class MatchDetailScreen extends StatefulWidget {
  final CricScoreMatch match;

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

  final List<_LiveEvent> _liveEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadScorecard();
    _generateLiveEvents();

    if (widget.match.isLive) {
      _refreshTimer =
          Timer.periodic(const Duration(seconds: 60), (_) => _loadScorecard());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadScorecard() async {
    setState(() => _isLoading = true);
    // getMatchScorecard uses the match id from cricScore — same UUID
    final sc =
        await CricketApiService.getMatchScorecard(widget.match.id);
    if (mounted) {
      setState(() {
        _scorecard = sc;
        _isLoading = false;
      });
    }
  }

  void _generateLiveEvents() {
    if (!widget.match.isLive) return;
    _liveEvents.addAll([
      _LiveEvent(type: 'ball',   over: '44.3', desc: 'Good length delivery outside off, defended back.',          runs: 0, isWicket: false),
      _LiveEvent(type: 'four',   over: '44.2', desc: 'Short ball, pulled over mid-wicket to the fence!',          runs: 4, isWicket: false),
      _LiveEvent(type: 'ball',   over: '44.1', desc: 'Driven through covers for a comfortable single.',           runs: 1, isWicket: false),
      _LiveEvent(type: 'wicket', over: '43.6', desc: 'LBW! Sweeping across the line, hits pad plumb in front!',   runs: 0, isWicket: true),
      _LiveEvent(type: 'six',    over: '43.4', desc: 'Slog sweep over deep mid-wicket, goes all the way!',        runs: 6, isWicket: false),
      _LiveEvent(type: 'ball',   over: '43.2', desc: 'Driven through mid-on, they run two.',                      runs: 2, isWicket: false),
      _LiveEvent(type: 'wicket', over: '42.1', desc: 'Caught behind! Nicked one driving away from the body.',     runs: 0, isWicket: true),
    ]);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final match      = widget.match;
    final typeColor  = AppTheme.matchTypeColor(match.matchType);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          _buildHeader(match, typeColor),
          SliverToBoxAdapter(child: _buildScoreHeader(match)),
          SliverToBoxAdapter(child: _buildTabBar()),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScorecardTab(),
                _buildLiveTab(),
                _buildInfoTab(match),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(CricScoreMatch match, Color typeColor) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: const Color.fromARGB(220, 100, 255, 72),
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios,
            color: AppTheme.textPrimary, size: 18),
      ),
      actions: [
        if (match.isLive)
          IconButton(
            onPressed: _loadScorecard,
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [typeColor.withOpacity(0.2), AppTheme.darkBg],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${match.t1Name} vs ${match.t2Name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Score header ───────────────────────────────────────────────────────────

  Widget _buildScoreHeader(CricScoreMatch match) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 16, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardDark,
            AppTheme.surfaceDark.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: match.isLive
              ? AppTheme.liveRed.withOpacity(0.4)
              : AppTheme.dividerColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _teamScoreBlock(match.t1Short, match.t1s, false)),
              Column(children: [
                match.isLive
                    ? _livePulse()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('VS',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w700)),
                      ),
              ]),
              Expanded(
                  child:
                      _teamScoreBlock(match.t2Short, match.t2s, true)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.dividerColor, height: 1),
          const SizedBox(height: 12),
          Text(
            match.status,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.goldYellow,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          if (match.isLive && _scorecard != null) ...[
            const SizedBox(height: 12),
            _currentPlayersRow(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _teamScoreBlock(
      String shortName, String scoreStr, bool alignRight) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(shortName,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        scoreStr.isEmpty
            ? const Text('Yet to bat',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13))
            : Text(scoreStr,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _livePulse() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (_, value, __) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.liveRed.withOpacity(0.8 * value),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('● LIVE',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
      ),
      onEnd: () => setState(() {}),
    );
  }

  Widget _currentPlayersRow() {
    if (_scorecard == null) return const SizedBox();
    final lastInnings = _scorecard!.scorecard.lastOrNull;
    if (lastInnings == null) return const SizedBox();

    final batsmen = lastInnings.batsmen
        .where((b) => b.isCurrentBatsman)
        .take(2)
        .toList();
    final bowler = lastInnings.bowlers
            .where((b) => b.isCurrentBowler)
            .firstOrNull ??
        (lastInnings.bowlers.isNotEmpty
            ? lastInnings.bowlers.last
            : null);

    final displayBatsmen =
        batsmen.isNotEmpty ? batsmen : lastInnings.batsmen.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
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
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
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
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ]),
                    )),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 70,
            color: AppTheme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.sports_baseball,
                        color: Colors.orange, size: 12),
                    SizedBox(width: 4),
                    Text('BOWLING',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 6),
                if (bowler != null) ...[
                  Text(bowler.name.split(' ').last,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  Text(
                      '${bowler.o}-${bowler.m}-${bowler.r}-${bowler.w}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12)),
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
        tabs: const [
          Tab(text: 'SCORECARD'),
          Tab(text: 'LIVE'),
          Tab(text: 'INFO'),
        ],
      ),
    );
  }

  // ── Scorecard tab ──────────────────────────────────────────────────────────

  Widget _buildScorecardTab() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen));
    }
    if (_scorecard == null) {
      return const Center(
          child: Text('Scorecard not available',
              style: TextStyle(color: AppTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scorecard!.scorecard.length,
      itemBuilder: (_, index) {
        final innings = _scorecard!.scorecard[index];
        final isLast  = index == _scorecard!.scorecard.length - 1;
        return Column(children: [
          ScorecardWidget(
            innings: innings,
            isCurrentInnings: widget.match.isLive && isLast,
          ),
          if (index < _scorecard!.scorecard.length - 1) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.dividerColor, thickness: 2),
            const SizedBox(height: 16),
          ],
        ]);
      },
    );
  }

  // ── Live tab ───────────────────────────────────────────────────────────────

  Widget _buildLiveTab() {
    if (!widget.match.isLive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event, color: AppTheme.upcomingBlue, size: 48),
            const SizedBox(height: 16),
            const Text('Match not started yet',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    if (_liveEvents.isEmpty) {
      return const Center(
          child: Text('No live events available',
              style: TextStyle(color: AppTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _liveEvents.length,
      itemBuilder: (_, i) => _eventCard(_liveEvents[i], i),
    );
  }

  Widget _eventCard(_LiveEvent event, int index) {
    Color color;
    IconData icon;
    switch (event.type) {
      case 'six':    color = AppTheme.goldYellow;    icon = Icons.star;           break;
      case 'four':   color = AppTheme.accentGreen;   icon = Icons.looks_4;        break;
      case 'wicket': color = AppTheme.liveRed;       icon = Icons.close_rounded;  break;
      default:       color = AppTheme.textSecondary; icon = Icons.circle_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.isWicket
              ? AppTheme.liveRed.withOpacity(0.3)
              : event.runs == 6
                  ? AppTheme.goldYellow.withOpacity(0.3)
                  : event.runs == 4
                      ? AppTheme.accentGreen.withOpacity(0.2)
                      : Colors.transparent,
        ),
        boxShadow: event.isWicket || event.runs >= 4
            ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(6)),
            child: Text(event.over,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Center(
              child: event.runs > 0 && event.type != 'wicket'
                  ? Text('${event.runs}',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800))
                  : Icon(icon, color: color, size: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(event.desc,
                style: TextStyle(
                    color: event.isWicket
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: event.isWicket
                        ? FontWeight.w600
                        : FontWeight.w400)),
          ),
        ],
      ),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.05, end: 0);
  }

  // ── Info tab ───────────────────────────────────────────────────────────────

  Widget _buildInfoTab(CricScoreMatch match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoSection('Match Details', [
          _infoRow(Icons.sports_cricket, 'Format',
              match.matchType.isEmpty ? 'N/A' : match.matchType.toUpperCase()),
          _infoRow(Icons.emoji_events_outlined, 'Series', match.series),
          _infoRow(Icons.calendar_today, 'Date & Time', () {
            try {
              final dt = DateTime.parse(match.dateTimeGMT).toLocal();
              return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            } catch (_) {
              return match.dateTimeGMT;
            }
          }()),
          _infoRow(Icons.info_outline, 'Status', match.status),
        ]),
        const SizedBox(height: 16),
        _infoSection('Teams', [
          _infoRow(Icons.people_outline, 'Team 1', match.t1Name),
          _infoRow(Icons.people_outline, 'Team 2', match.t2Name),
        ]),
        if (_scorecard != null && _scorecard!.series.isNotEmpty) ...[
          const SizedBox(height: 16),
          _infoSection('Series', [
            ..._scorecard!.series.map((s) =>
                _infoRow(Icons.emoji_events_outlined, 'Series', s.name)),
          ]),
        ],
      ],
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.dividerColor, height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }
}

// ── Data classes ───────────────────────────────────────────────────────────────

class _LiveEvent {
  final String type;
  final String over;
  final String desc;
  final int    runs;
  final bool   isWicket;

  const _LiveEvent({
    required this.type,
    required this.over,
    required this.desc,
    required this.runs,
    required this.isWicket,
  });
}