import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/scorecard_model.dart';
import '../theme/app_theme.dart';

class ScorecardWidget extends StatelessWidget {
  final ScorecardInnings innings;
  final bool isCurrentInnings;

  const ScorecardWidget({
    super.key,
    required this.innings,
    this.isCurrentInnings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Innings Header
        _buildInningsHeader(),
        const SizedBox(height: 12),

        // Batting Section
        _buildSectionHeader('BATTING', Icons.sports_cricket, AppTheme.accentGreen),
        const SizedBox(height: 8),
        _buildBattingTable(),
        const SizedBox(height: 12),

        // Extras
        if (innings.extras.isNotEmpty) _buildExtras(),
        const SizedBox(height: 12),

        // Bowling Section
        _buildSectionHeader('BOWLING', Icons.sports_baseball, Colors.orange),
        const SizedBox(height: 8),
        _buildBowlingTable(),
        const SizedBox(height: 16),

        // Fall of Wickets
        if (innings.fow.isNotEmpty) _buildFallOfWickets(),
      ],
    );
  }

  Widget _buildInningsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentInnings
              ? [
                  AppTheme.primaryGreen.withOpacity(0.3),
                  AppTheme.cardDark,
                ]
              : [AppTheme.surfaceDark, AppTheme.cardDark],
        ),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentInnings
            ? Border.all(color: AppTheme.accentGreen.withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    innings.team,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isCurrentInnings) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppTheme.accentGreen.withOpacity(0.5)),
                      ),
                      child: const Text(
                        'BATTING NOW',
                        style: TextStyle(
                          color: AppTheme.accentGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                'Innings ${innings.inning}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${innings.total.r}/${innings.total.w}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '(${innings.total.o} ov) • RR: ${innings.total.rr.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBattingTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 4,
                  child: Text('BATTER',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ),
                SizedBox(
                  width: 30,
                  child: Text('R',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 30,
                  child: Text('B',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 26,
                  child: Text('4s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 26,
                  child: Text('6s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 40,
                  child: Text('SR',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.dividerColor, height: 1),
          ...innings.batsmen.asMap().entries.map((entry) {
            final i = entry.key;
            final batsman = entry.value;
            final isCurrent = batsman.isCurrentBatsman;

            return Column(
              children: [
                Container(
                  color: isCurrent
                      ? AppTheme.accentGreen.withOpacity(0.05)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                if (isCurrent)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.accentGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    batsman.name,
                                    style: TextStyle(
                                      color: isCurrent
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: isCurrent
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${batsman.r}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isCurrent
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${batsman.b}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 26,
                            child: Text(
                              '${batsman.fours}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 26,
                            child: Text(
                              '${batsman.sixes}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              batsman.sr.toStringAsFixed(1),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      if (batsman.dismissal.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            batsman.dismissal,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            'batting',
                            style: TextStyle(
                              color: AppTheme.accentGreen.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (i < innings.batsmen.length - 1)
                  const Divider(
                      color: AppTheme.dividerColor,
                      height: 1,
                      indent: 12,
                      endIndent: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBowlingTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 4,
                  child: Text('BOWLER',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ),
                SizedBox(
                  width: 30,
                  child: Text('O',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 26,
                  child: Text('M',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 30,
                  child: Text('R',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 26,
                  child: Text('W',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 40,
                  child: Text('ECO',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.dividerColor, height: 1),
          ...innings.bowlers.asMap().entries.map((entry) {
            final i = entry.key;
            final bowler = entry.value;
            final isCurrent = bowler.isCurrentBowler;

            return Column(
              children: [
                Container(
                  color: isCurrent
                      ? Colors.orange.withOpacity(0.05)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            if (isCurrent)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                bowler.name,
                                style: TextStyle(
                                  color: isCurrent
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text('${bowler.o}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ),
                      SizedBox(
                        width: 26,
                        child: Text('${bowler.m}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text('${bowler.r}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ),
                      SizedBox(
                        width: 26,
                        child: Text(
                          '${bowler.w}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: bowler.w > 0
                                ? Colors.orange
                                : AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: bowler.w > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          bowler.eco.toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: bowler.eco < 4.0
                                ? AppTheme.accentGreen
                                : bowler.eco > 6.0
                                    ? AppTheme.liveRed
                                    : AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < innings.bowlers.length - 1)
                  const Divider(
                      color: AppTheme.dividerColor,
                      height: 1,
                      indent: 12,
                      endIndent: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExtras() {
    if (innings.extras.isEmpty) return const SizedBox();
    final ext = innings.extras.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('Extras: ',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          Text(
            '${ext.total} (b ${ext.b}, lb ${ext.lb}, wd ${ext.wd}, nb ${ext.nb})',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFallOfWickets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('FALL OF WICKETS', Icons.arrow_downward, Colors.red.shade300),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: innings.fow
              .map((f) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${f.num}-${f.r} (${f.batsman}, ${f.o})',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
