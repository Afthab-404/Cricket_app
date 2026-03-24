import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cric_score_model.dart';
import '../theme/app_theme.dart';

class UpcomingMatchCard extends StatelessWidget {
  final CricScoreMatch match;
  final int index;

  const UpcomingMatchCard(
      {super.key, required this.match, required this.index});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.matchTypeColor(match.matchType);

    String formattedDate = '';
    String formattedTime = '';
    try {
      final dt = DateTime.parse(match.dateTimeGMT).toLocal();
      formattedDate = DateFormat('EEE, dd MMM yyyy').format(dt);
      formattedTime = DateFormat('hh:mm a').format(dt);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.upcomingBlue.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              _pill('UPCOMING', AppTheme.upcomingBlue),
              const SizedBox(width: 8),
              if (match.matchType.isNotEmpty)
                _pill(match.matchType.toUpperCase(), typeColor),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formattedDate,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
                Text(formattedTime,
                    style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ]),
            const SizedBox(height: 12),

            // Teams row
            Row(children: [
              _teamPill(match.t1Short, match.t1img),
              Expanded(
                child: Row(children: [
                  Expanded(
                      child: Divider(
                          color: AppTheme.dividerColor.withOpacity(0.5))),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('VS',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                      child: Divider(
                          color: AppTheme.dividerColor.withOpacity(0.5))),
                ]),
              ),
              _teamPill(match.t2Short, match.t2img),
            ]),
            const SizedBox(height: 10),

            // Series
            Row(children: [
              const Icon(Icons.emoji_events_outlined,
                  color: AppTheme.textSecondary, size: 12),
              const SizedBox(width: 5),
              Expanded(
                child: Text(match.series,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }

  Widget _teamPill(String shortName, String imgUrl) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.dividerColor, width: 1.5),
          ),
          child: imgUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initials(shortName),
                  ),
                )
              : _initials(shortName),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: Text(shortName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _initials(String s) {
    return Center(
      child: Text(
        s.length > 3 ? s.substring(0, 3) : s,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800),
      ),
    );
  }
}