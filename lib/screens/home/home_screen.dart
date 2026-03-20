import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/widgets/empty_state_widget.dart';
import 'package:fan_arena/widgets/sport_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _countdownText(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);
    if (diff.isNegative) return 'Past';
    if (diff.inHours < 1) return 'Starting soon';
    if (diff.inHours < 24) return 'Today';
    if (diff.inHours < 48) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays} days';
    return 'In ${(diff.inDays / 7).ceil()} weeks';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final nickname = provider.profile.nickname;
    final upcoming = provider.upcomingMatches;
    final favoriteTeams = provider.favoriteTeams;
    final recentJournal = provider.recentJournalEntries;
    final pinnedTournaments = provider.pinnedTournaments;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool allEmpty = upcoming.isEmpty &&
        provider.teams.isEmpty &&
        recentJournal.isEmpty &&
        pinnedTournaments.isEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Hello, $nickname',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: allEmpty
          ? EmptyStateWidget(
              icon: Icons.sports,
              imagePath: 'assets/images/onboarding_welcome.png',
              title: 'Welcome to FanArena',
              subtitle:
                  'Start by adding your favorite teams and planning match days',
              buttonLabel: 'Get Started',
              onButtonPressed: () => Navigator.pushNamed(context, '/add-team'),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppCorners.lg),
                  child: Image.asset(
                    'assets/images/header_home.png',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _HeroSummaryCard(
                  teamsCount: provider.totalTeams,
                  plannedCount: provider.plannedMatches,
                  watchedCount: provider.watchedMatches,
                  accuracy: provider.predictionAccuracy,
                ),
                const SizedBox(height: AppSpacing.xl),
                const _QuickActionsRow(),
                const SizedBox(height: AppSpacing.xxl),

                _SectionHeader(
                  title: 'Upcoming Matches',
                  onSeeAll: upcoming.isNotEmpty
                      ? () => Navigator.pushNamed(context, '/planner')
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (upcoming.isEmpty)
                  const _EmptyHint('No upcoming matches planned')
                else
                  _UpcomingMatchesList(matches: upcoming, isDark: isDark),

                const SizedBox(height: AppSpacing.xxl),
                _SectionHeader(
                  title: 'Favorite Teams',
                  onSeeAll: provider.teams.isNotEmpty
                      ? () => Navigator.pushNamed(context, '/teams')
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (favoriteTeams.isEmpty)
                  const _EmptyHint('Mark teams as favorites to see them here')
                else
                  _TeamPillsList(teams: favoriteTeams),

                if (pinnedTournaments.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionHeader(
                    title: 'Pinned Tournaments',
                    onSeeAll: () =>
                        Navigator.pushNamed(context, '/tournaments'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _PinnedTournamentsList(
                    tournaments: pinnedTournaments,
                    isDark: isDark,
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),
                _SectionHeader(
                  title: 'Recent Journal',
                  onSeeAll: recentJournal.isNotEmpty
                      ? () => Navigator.pushNamed(context, '/journal')
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (recentJournal.isEmpty)
                  const _EmptyHint('Start journaling your fan experiences')
                else
                  _RecentJournalList(
                    entries: recentJournal.take(3).toList(),
                    isDark: isDark,
                  ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Summary Card
// ---------------------------------------------------------------------------

class _HeroSummaryCard extends StatelessWidget {
  final int teamsCount;
  final int plannedCount;
  final int watchedCount;
  final double accuracy;

  const _HeroSummaryCard({
    required this.teamsCount,
    required this.plannedCount,
    required this.watchedCount,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppCorners.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatColumn(
            icon: Icons.groups_outlined,
            value: '$teamsCount',
            label: 'Teams',
          ),
          _StatColumn(
            icon: Icons.event_outlined,
            value: '$plannedCount',
            label: 'Planned',
          ),
          _StatColumn(
            icon: Icons.visibility_outlined,
            value: '$watchedCount',
            label: 'Watched',
          ),
          _StatColumn(
            icon: Icons.trending_up,
            value: '${(accuracy * 100).round()}%',
            label: 'Accuracy',
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions
// ---------------------------------------------------------------------------

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.event,
            label: 'Add Match',
            onTap: () => Navigator.pushNamed(context, '/add-match'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionChip(
            icon: Icons.groups,
            label: 'Add Team',
            onTap: () => Navigator.pushNamed(context, '/add-team'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionChip(
            icon: Icons.book,
            label: 'Journal',
            onTap: () => Navigator.pushNamed(context, '/add-journal'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionChip(
            icon: Icons.trending_up,
            label: 'Predict',
            onTap: () => Navigator.pushNamed(context, '/add-prediction'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppCorners.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppCorners.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty Hint
// ---------------------------------------------------------------------------

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming Matches
// ---------------------------------------------------------------------------

class _UpcomingMatchesList extends StatelessWidget {
  final List matches;
  final bool isDark;

  const _UpcomingMatchesList({required this.matches, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final match = matches[index];
          final dateStr = DateFormat('MMM d, HH:mm').format(match.dateTime);
          final countdown = HomeScreen._countdownText(match.dateTime);
          final statusColor = AppConstants.matchStatusColor(match.status);
          final statusLabel = AppConstants.matchStatusLabel(match.status);

          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/match-details',
              arguments: match.id,
            ),
            child: SizedBox(
              width: 210,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppCorners.md),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SportIcon(sport: match.sport, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              countdown,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (match.reminderEnabled)
                            Icon(
                              Icons.notifications_active,
                              size: 14,
                              color: AppColors.accent,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${match.teamName} vs ${match.opponentName}',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppCorners.sm),
                        ),
                        child: Text(
                          statusLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Favorite Teams Pills
// ---------------------------------------------------------------------------

class _TeamPillsList extends StatelessWidget {
  final List teams;

  const _TeamPillsList({required this.teams});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teams.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final team = teams[index];
          final teamColor = AppColors.colorFromTag(team.colorTag);
          return Material(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppCorners.xl),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppCorners.xl),
              onTap: () => Navigator.pushNamed(
                context,
                '/edit-team',
                arguments: team,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: teamColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      team.name,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      AppConstants.sportIcon(team.sport),
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pinned Tournaments
// ---------------------------------------------------------------------------

class _PinnedTournamentsList extends StatelessWidget {
  final List tournaments;
  final bool isDark;

  const _PinnedTournamentsList({
    required this.tournaments,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tournaments.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final t = tournaments[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/edit-tournament',
              arguments: t,
            ),
            child: SizedBox(
              width: 180,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppCorners.md),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SportIcon(sport: t.sport, size: 14),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              t.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            t.seasonLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                          ),
                          const Spacer(),
                          if (t.favoriteParticipants.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppCorners.sm),
                              ),
                              child: Text(
                                '${t.favoriteParticipants.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent Journal
// ---------------------------------------------------------------------------

class _RecentJournalList extends StatelessWidget {
  final List entries;
  final bool isDark;

  const _RecentJournalList({required this.entries, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries.map((entry) {
        final moodColor = AppConstants.moodColor(entry.mood);
        final dateStr = DateFormat('MMM d').format(entry.date);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/edit-journal',
              arguments: entry,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppCorners.md),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: moodColor.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppCorners.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppConstants.moodIcon(entry.mood),
                                size: 14,
                                color: moodColor,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                entry.mood,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: moodColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      entry.body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
