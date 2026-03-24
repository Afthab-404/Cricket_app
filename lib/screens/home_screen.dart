import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cric_score_model.dart';
import '../services/cricket_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_match_card.dart';
import '../widgets/upcoming_match_card.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<CricScoreMatch> _liveMatches     = [];
  List<CricScoreMatch> _upcomingMatches = [];

  bool _isLoadingLive     = true;
  bool _isLoadingUpcoming = true;
  bool _upcomingError     = false;
  bool _isUsingMock       = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 2), (_) => _loadLive());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadLive(), _loadUpcoming()]);
  }

  Future<void> _loadLive({bool force = false}) async {
    if (mounted) setState(() => _isLoadingLive = true);
    try {
      final matches =
          await CricketApiService.getLiveMatches(forceRefresh: force);
      if (mounted) setState(() {
        _liveMatches   = matches;
        _isLoadingLive = false;
        _checkMock();
      });
    } catch (_) {
      if (mounted) setState(() { _liveMatches = []; _isLoadingLive = false; });
    }
  }

  Future<void> _loadUpcoming({bool force = false}) async {
    if (mounted) setState(() { _isLoadingUpcoming = true; _upcomingError = false; });
    try {
      final matches =
          await CricketApiService.getUpcomingMatches(forceRefresh: force);
      if (mounted) setState(() {
        _upcomingMatches   = matches;
        _isLoadingUpcoming = false;
        _checkMock();
      });
    } catch (_) {
      if (mounted) setState(() { _isLoadingUpcoming = false; _upcomingError = true; });
    }
  }

  void _checkMock() {
    final all = [..._liveMatches, ..._upcomingMatches];
    _isUsingMock = all.isNotEmpty && all.every((x) => x.id.startsWith('mock-'));
  }

  Future<void> _onRefreshLive() async {
    CricketApiService.invalidateCache();
    await _loadLive(force: true);
  }

  Future<void> _onRefreshUpcoming() async {
    CricketApiService.invalidateCache();
    await _loadUpcoming(force: true);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  // Column layout: fixed header (app bar + tabs) on top, Expanded TabBarView
  // below. Nothing scrolls except the ListView inside each tab.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed header ───────────────────────────────────────────────
            _buildHeader(),
            _buildTabBar(),
            if (_isUsingMock) _buildDemoBanner(),

            // ── Scrollable tab content fills the rest ──────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLiveTab(), _buildUpcomingTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header (static, never scrolls) ────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF1A2744), Color(0xFF0A1628)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.accentGreen.withOpacity(0.3)),
              ),
              child: const Icon(Icons.sports_cricket,
                  color: AppTheme.accentGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CricketLive',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Text('Live Scores & Updates',
                  style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.8),
                      fontSize: 12)),
            ]),
            const Spacer(),
            IconButton(
              onPressed: () {
                CricketApiService.invalidateCache();
                _loadData();
              },
              icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
              tooltip: 'Refresh',
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _chip('${_liveMatches.length} LIVE', AppTheme.liveRed),
            const SizedBox(width: 8),
            _chip('${_upcomingMatches.length} UPCOMING', AppTheme.upcomingBlue),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }

  // ── Tab bar (static, never scrolls) ───────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.darkBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
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
              Color.fromARGB(255, 33, 245, 47),
              AppTheme.accentGreen,
            ]),
            borderRadius: BorderRadius.circular(10),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.circle, size: 8, color: AppTheme.liveRed),
                  SizedBox(width: 4),
                  Text('LIVE'),
                ],
              ),
            ),
            const Tab(text: 'UPCOMING'),
          ],
        ),
      ),
    );
  }

  // ── Demo banner ────────────────────────────────────────────────────────────

  Widget _buildDemoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.goldYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.goldYellow.withOpacity(0.35)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, color: AppTheme.goldYellow, size: 16),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Showing demo data — API limit reached. '
            'Live data resumes tomorrow automatically.',
            style: TextStyle(
                color: AppTheme.goldYellow, fontSize: 12, height: 1.4),
          ),
        ),
        GestureDetector(
          onTap: () { CricketApiService.invalidateCache(); _loadData(); },
          child: const Icon(Icons.refresh, color: AppTheme.goldYellow, size: 16),
        ),
      ]),
    );
  }

  // ── Tab content ────────────────────────────────────────────────────────────

  Widget _buildLiveTab() {
    if (_isLoadingLive) return _shimmer();

    if (_liveMatches.isEmpty) {
      return _emptyState(
        icon: Icons.sports_cricket,
        title: 'No Live Matches',
        subtitle: 'No matches are being played right now.\nCheck back later.',
        color: AppTheme.liveRed,
        showRetry: true,
        onRetry: _onRefreshLive,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefreshLive,
      color: AppTheme.accentGreen,
      backgroundColor: AppTheme.cardDark,
      child: ListView.builder(
        key: const PageStorageKey('live'),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _liveMatches.length,
        itemBuilder: (_, i) => LiveMatchCard(
          match: _liveMatches[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MatchDetailScreen(match: _liveMatches[i])),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_isLoadingUpcoming) return _shimmer();

    if (_upcomingError) {
      return _emptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to Load',
        subtitle: 'Check your connection and try again',
        color: AppTheme.upcomingBlue,
        showRetry: true,
        onRetry: _onRefreshUpcoming,
      );
    }

    if (_upcomingMatches.isEmpty) {
      return _emptyState(
        icon: Icons.event_note,
        title: 'No Upcoming Matches',
        subtitle: 'Check back soon for upcoming fixtures',
        color: AppTheme.upcomingBlue,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefreshUpcoming,
      color: AppTheme.accentGreen,
      backgroundColor: AppTheme.cardDark,
      child: ListView.builder(
        key: const PageStorageKey('upcoming'),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _upcomingMatches.length,
        itemBuilder: (_, i) =>
            UpcomingMatchCard(match: _upcomingMatches[i], index: i),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _shimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: 4,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 120,
          decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5)),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.2),
                  foregroundColor: color,
                  elevation: 0,
                  side: BorderSide(color: color.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}