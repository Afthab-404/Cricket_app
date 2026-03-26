import 'package:flutter/material.dart';
import '../models/cric_score_model.dart';
import '../theme/app_theme.dart';

class LiveMatchCard extends StatefulWidget {
  final LiveMatch match;
  final VoidCallback onTap;

  const LiveMatchCard({super.key, required this.match, required this.onTap});

  @override
  State<LiveMatchCard> createState() => _LiveMatchCardState();
}

class _LiveMatchCardState extends State<LiveMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match     = widget.match;
    final typeColor = AppTheme.matchTypeColor(match.matchType);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.liveRed.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.liveRed.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(children: [
                _liveBadge(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(match.name,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (match.matchType.isNotEmpty)
                  _typeBadge(match.matchType, typeColor),
              ]),
              const SizedBox(height: 14),

              // Scores
              _scoresRow(match),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.dividerColor, height: 1),
              const SizedBox(height: 10),

              // Status + venue
              Row(children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.goldYellow, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(match.status,
                      style: const TextStyle(
                          color: AppTheme.goldYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      maxLines: 2),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary, size: 18),
              ]),
              if (match.venue.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppTheme.textSecondary, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(match.venue,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoresRow(LiveMatch match) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _teamCol(match.t1Short, match.t1Innings, true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text('VS',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
        Expanded(child: _teamCol(match.t2Short, match.t2Innings, false)),
      ],
    );
  }

  Widget _teamCol(
      String shortName, List<LiveInnings> innings, bool isLeft) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(shortName,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        if (innings.isEmpty)
          const Text('Yet to bat',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))
        else
          ...innings.map((inn) => Text(
                inn.scoreStr,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              )),
      ],
    );
  }

  Widget _liveBadge() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.liveRed.withOpacity(0.8 + 0.2 * _pulse.value),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
        ]),
      ),
    );
  }

  Widget _typeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(type.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}