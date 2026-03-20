import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/widgets/sport_icon.dart';

class MatchDetailsScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final match = provider.getMatchById(matchId);

    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
              SizedBox(height: AppSpacing.lg),
              Text('Match not found'),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prediction = provider.getPredictionForMatch(matchId);
    final linkedJournals = provider.journalEntries
        .where((e) => e.matchId == matchId)
        .toList();
    final dateFormatted =
        DateFormat('EEEE, MMMM d, yyyy • HH:mm').format(match.dateTime);
    final statusColor = AppConstants.matchStatusColor(match.status);
    final statusLabel = AppConstants.matchStatusLabel(match.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('${match.teamName} vs ${match.opponentName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-match',
                arguments: match),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCard(
              teamName: match.teamName,
              opponentName: match.opponentName,
              sport: match.sport,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.lg),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppCorners.md),
                side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date & Time',
                      value: dateFormatted,
                    ),
                    if (match.tournament != null &&
                        match.tournament!.isNotEmpty) ...[
                      const Divider(height: AppSpacing.xxl),
                      _DetailRow(
                        icon: Icons.emoji_events,
                        label: 'Tournament',
                        value: match.tournament!,
                      ),
                    ],
                    if (match.watchMethod != null &&
                        match.watchMethod!.isNotEmpty) ...[
                      const Divider(height: AppSpacing.xxl),
                      _DetailRow(
                        icon: Icons.tv,
                        label: 'Watch Method',
                        value: match.watchMethod!,
                      ),
                    ],
                    const Divider(height: AppSpacing.xxl),
                    _DetailRow(
                      icon: Icons.flag,
                      label: 'Status',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppCorners.sm),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (match.reminderEnabled) ...[
                      const Divider(height: AppSpacing.xxl),
                      _DetailRow(
                        icon: Icons.notifications_active,
                        label: 'Reminder',
                        value: _reminderLabel(match.reminderOffsetMinutes),
                      ),
                    ],
                    if (match.notes != null && match.notes!.isNotEmpty) ...[
                      const Divider(height: AppSpacing.xxl),
                      _DetailRow(
                        icon: Icons.notes,
                        label: 'Notes',
                        value: match.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (prediction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(title: 'Prediction'),
              const SizedBox(height: AppSpacing.sm),
              _PredictionCard(prediction: prediction, isDark: isDark),
            ],

            if (linkedJournals.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(title: 'Journal Entries'),
              const SizedBox(height: AppSpacing.sm),
              ...linkedJournals.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.md),
                      side: BorderSide(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(entry.title),
                      subtitle: Text(
                        DateFormat('MMM d, yyyy').format(
                            DateTime.parse(entry.dateIso)),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                          context, '/edit-journal',
                          arguments: entry),
                    ),
                  )),
            ],

            const SizedBox(height: AppSpacing.xxl),

            Row(
              children: [
                if (match.status != 'watched')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<AppDataProvider>()
                          .updateMatchStatus(match.id, 'watched'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark Watched'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                if (match.status != 'watched' && match.status != 'missed')
                  const SizedBox(width: AppSpacing.md),
                if (match.status != 'missed')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<AppDataProvider>()
                          .updateMatchStatus(match.id, 'missed'),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Mark Missed'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (prediction == null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(
                          context, '/add-prediction',
                          arguments: matchId),
                      icon: const Icon(Icons.psychology),
                      label: const Text('Add Prediction'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                if (prediction == null) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, '/add-journal',
                        arguments: {
                          'matchId': matchId,
                          'teamId': null,
                        }),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Add Journal'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _reminderLabel(int minutes) {
    for (final entry in AppConstants.reminderOffsets.entries) {
      if (entry.value == minutes) return entry.key;
    }
    return '$minutes min';
  }
}

class _HeaderCard extends StatelessWidget {
  final String teamName;
  final String opponentName;
  final String sport;
  final bool isDark;

  const _HeaderCard({
    required this.teamName,
    required this.opponentName,
    required this.sport,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppCorners.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          children: [
            SportIcon(
              sport: sport,
              size: 32,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              teamName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'vs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
            ),
            Text(
              opponentName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              if (value != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(value!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final dynamic prediction;
  final bool isDark;

  const _PredictionCard({required this.prediction, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        AppConstants.predictionStatusColor(prediction.resultStatus);
    final statusLabel =
        AppConstants.predictionStatusLabel(prediction.resultStatus);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.md),
        onTap: () => Navigator.pushNamed(context, '/edit-prediction',
            arguments: prediction),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Winner: ${prediction.predictedWinner}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppCorners.sm),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < prediction.confidence ? Icons.star : Icons.star_border,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
              ),
              if (prediction.reason != null &&
                  prediction.reason!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  prediction.reason!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
