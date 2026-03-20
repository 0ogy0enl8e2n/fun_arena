import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/tournament_item.dart';
import 'package:fan_arena/widgets/empty_state_widget.dart';

enum _SortMode { newest, name, season }

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  _SortMode _sortMode = _SortMode.newest;

  List<TournamentItem> _sorted(List<TournamentItem> items) {
    final list = List<TournamentItem>.from(items);
    switch (_sortMode) {
      case _SortMode.newest:
        list.sort((a, b) => b.id.compareTo(a.id));
      case _SortMode.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _SortMode.season:
        list.sort((a, b) => b.seasonLabel.compareTo(a.seasonLabel));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTournaments = _sorted(provider.tournaments);
    final pinned = allTournaments.where((t) => t.isPinned).toList();
    final unpinned = allTournaments.where((t) => !t.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          PopupMenuButton<_SortMode>(
            icon: const Icon(Icons.sort),
            onSelected: (mode) => setState(() => _sortMode = mode),
            itemBuilder: (_) => [
              _sortMenuItem(_SortMode.newest, 'Newest'),
              _sortMenuItem(_SortMode.name, 'Name'),
              _sortMenuItem(_SortMode.season, 'Season'),
            ],
          ),
        ],
      ),
      body: allTournaments.isEmpty
          ? EmptyStateWidget(
              icon: Icons.emoji_events,
              imagePath: 'assets/images/empty_tournaments.png',
              title: 'No tournaments yet',
              subtitle:
                  'Create tournament collections to track your favorite competitions',
              buttonLabel: 'Add Tournament',
              onButtonPressed: () =>
                  Navigator.pushNamed(context, '/add-tournament'),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              children: [
                if (pinned.isNotEmpty) ...[
                  _SectionHeader(title: 'Pinned', isDark: isDark),
                  ...pinned.map((t) => _TournamentCard(
                        tournament: t,
                        isDark: isDark,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/edit-tournament',
                          arguments: t,
                        ),
                        onLongPress: () => provider.toggleTournamentPin(t.id),
                        onDismissed: () =>
                            _confirmDelete(context, provider, t),
                      )),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (unpinned.isNotEmpty) ...[
                  if (pinned.isNotEmpty)
                    _SectionHeader(title: 'All', isDark: isDark),
                  ...unpinned.map((t) => _TournamentCard(
                        tournament: t,
                        isDark: isDark,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/edit-tournament',
                          arguments: t,
                        ),
                        onLongPress: () => provider.toggleTournamentPin(t.id),
                        onDismissed: () =>
                            _confirmDelete(context, provider, t),
                      )),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_tournaments',
        onPressed: () => Navigator.pushNamed(context, '/add-tournament'),
        child: const Icon(Icons.add),
      ),
    );
  }

  PopupMenuItem<_SortMode> _sortMenuItem(_SortMode mode, String label) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          if (_sortMode == mode)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(Icons.check, size: 18),
            ),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppDataProvider provider,
    TournamentItem tournament,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: const Text(
          'Are you sure you want to delete this tournament?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await provider.deleteTournament(tournament.id);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentItem tournament;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDismissed;

  const _TournamentCard({
    required this.tournament,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Dismissible(
      key: ValueKey(tournament.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDismissed();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppCorners.md),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tournament.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tournament.isPinned)
                      Icon(Icons.push_pin, size: 18, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      AppConstants.sportIcon(tournament.sport),
                      size: 16,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      tournament.sport,
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Icon(Icons.date_range, size: 14, color: secondaryColor),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      tournament.seasonLabel,
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                    const Spacer(),
                    if (tournament.favoriteParticipants.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppCorners.sm),
                        ),
                        child: Text(
                          '${tournament.favoriteParticipants.length} fav',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (tournament.notes != null && tournament.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    tournament.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: secondaryColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
