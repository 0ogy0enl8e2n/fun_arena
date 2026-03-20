import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/match_plan.dart';
import 'package:fan_arena/widgets/empty_state_widget.dart';
import 'package:fan_arena/widgets/sport_icon.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  String _filter = 'all';

  static const _filters = ['all', 'planned', 'watched', 'missed'];
  static const _filterLabels = {
    'all': 'All',
    'planned': 'Planned',
    'watched': 'Watched',
    'missed': 'Missed',
  };

  List<MatchPlan> _applyFilter(List<MatchPlan> matches) {
    final filtered = _filter == 'all'
        ? List<MatchPlan>.from(matches)
        : matches.where((m) => m.status == _filter).toList();

    filtered.sort((a, b) {
      if (_filter == 'planned' || _filter == 'all') {
        return a.dateTime.compareTo(b.dateTime);
      }
      return b.dateTime.compareTo(a.dateTime);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final matches = _applyFilter(provider.matches);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Match Planner')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: _filters.map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(_filterLabels[f]!),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.event_note,
                    imagePath: 'assets/images/empty_planner.png',
                    title: 'No match plans yet',
                    subtitle: 'Start planning your match days',
                    buttonLabel: 'Add Match',
                    onButtonPressed: () =>
                        Navigator.pushNamed(context, '/add-match'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: matches.length,
                    itemBuilder: (context, index) =>
                        _MatchCard(match: matches[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_planner',
        onPressed: () => Navigator.pushNamed(context, '/add-match'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchPlan match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormatted =
        DateFormat('EEE, MMM d • HH:mm').format(match.dateTime);
    final statusColor = AppConstants.matchStatusColor(match.status);
    final statusLabel = AppConstants.matchStatusLabel(match.status);

    return Dismissible(
      key: Key(match.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: const Icon(Icons.check_circle, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final provider = context.read<AppDataProvider>();
        if (direction == DismissDirection.startToEnd) {
          await provider.updateMatchStatus(match.id, 'watched');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Match marked as watched'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          return false;
        } else {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Match'),
              content:
                  const Text('Are you sure you want to delete this match?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Delete',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await provider.deleteMatch(match.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Match deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppCorners.md),
          onTap: () => Navigator.pushNamed(context, '/match-details',
              arguments: match.id),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                SportIcon(sport: match.sport),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match.teamName} vs ${match.opponentName}',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dateFormatted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                      ),
                      if (match.tournament != null &&
                          match.tournament!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          match.tournament!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                        ),
                      ],
                      if (match.watchMethod != null &&
                          match.watchMethod!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(Icons.tv,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              match.watchMethod!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    if (match.reminderEnabled) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Icon(Icons.notifications_active,
                          size: 18, color: AppColors.accent),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
