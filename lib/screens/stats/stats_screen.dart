import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/providers/app_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final totalMatches = provider.matches.length;
    final missedMatches =
        provider.matches.where((m) => m.status == 'missed').length;
    final totalPredictions = provider.predictions.length;
    final correctPredictions =
        provider.predictions.where((p) => p.resultStatus == 'correct').length;
    final incorrectPredictions =
        provider.predictions.where((p) => p.resultStatus == 'incorrect').length;
    final pendingPredictions =
        provider.predictions.where((p) => p.resultStatus == 'pending').length;
    final watchRate =
        totalMatches > 0 ? provider.watchedMatches / totalMatches : 0.0;

    final allZero = provider.totalTeams == 0 &&
        totalMatches == 0 &&
        provider.totalJournalEntries == 0 &&
        provider.activeTournaments == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Stats Summary')),
      body: allZero
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Text(
                  'Start using the app to see your stats here',
                  style: textTheme.bodyLarge?.copyWith(color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SectionCard(
                  isDark: isDark,
                  child: Row(
                    children: [
                      _MetricBlock(
                        icon: Icons.groups,
                        label: 'Teams',
                        value: provider.totalTeams.toString(),
                      ),
                      _verticalDivider(isDark),
                      _MetricBlock(
                        icon: Icons.event,
                        label: 'Matches',
                        value: totalMatches.toString(),
                      ),
                      _verticalDivider(isDark),
                      _MetricBlock(
                        icon: Icons.psychology,
                        label: 'Accuracy',
                        value:
                            '${(provider.predictionAccuracy * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matches',
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _StatusChip(
                            label: 'Planned',
                            count: provider.plannedMatches,
                            color: AppConstants.matchStatusColor('planned'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _StatusChip(
                            label: 'Watched',
                            count: provider.watchedMatches,
                            color: AppConstants.matchStatusColor('watched'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _StatusChip(
                            label: 'Missed',
                            count: missedMatches,
                            color: AppConstants.matchStatusColor('missed'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppCorners.sm),
                        child: LinearProgressIndicator(
                          value: watchRate,
                          minHeight: 8,
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.success),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Watch rate: ${(watchRate * 100).toStringAsFixed(0)}%',
                        style:
                            textTheme.bodySmall?.copyWith(color: secondaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predictions',
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: provider.predictionAccuracy,
                                    strokeWidth: 6,
                                    backgroundColor: AppColors.success
                                        .withValues(alpha: 0.12),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.success),
                                  ),
                                ),
                                Text(
                                  '${(provider.predictionAccuracy * 100).toStringAsFixed(0)}%',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PredictionRow(
                                  label: 'Total',
                                  count: totalPredictions,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                _PredictionRow(
                                  label: 'Correct',
                                  count: correctPredictions,
                                  color: AppColors.success,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                _PredictionRow(
                                  label: 'Incorrect',
                                  count: incorrectPredictions,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                _PredictionRow(
                                  label: 'Pending',
                                  count: pendingPredictions,
                                  color: AppColors.warning,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Journal',
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            '${provider.totalJournalEntries} entries',
                            style: textTheme.bodySmall
                                ?.copyWith(color: secondaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: AppConstants.moods.map((mood) {
                          final count = provider.journalEntries
                              .where((e) => e.mood == mood)
                              .length;
                          if (count == 0) return const SizedBox.shrink();
                          final color = AppConstants.moodColor(mood);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppCorners.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(AppConstants.moodIcon(mood),
                                    size: 16, color: color),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  mood,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '$count',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionCard(
                  isDark: isDark,
                  child: Row(
                    children: [
                      _MetricBlock(
                        icon: Icons.emoji_events,
                        label: 'Tournaments',
                        value: provider.activeTournaments.toString(),
                      ),
                      _verticalDivider(isDark),
                      _MetricBlock(
                        icon: Icons.push_pin,
                        label: 'Pinned',
                        value: provider.pinnedTournaments.length.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
    );
  }

  Widget _verticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SectionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppCorners.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppCorners.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppCorners.sm),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _PredictionRow({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        Text(
          '$count',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
