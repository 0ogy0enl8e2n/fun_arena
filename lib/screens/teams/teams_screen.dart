import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/models/team_item.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/widgets/empty_state_widget.dart';
import 'package:fan_arena/widgets/sport_icon.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _searchQuery = '';
  String _selectedSport = 'All';

  List<String> _buildSportFilters(AppDataProvider provider) {
    final fromProfile = provider.profile.favoriteSports;
    final fromTeams = provider.teams.map((t) => t.sport).toSet();
    final allSports = <String>{...fromProfile, ...fromTeams};
    return ['All', ...allSports];
  }

  List<TeamItem> _filteredTeams(AppDataProvider provider) {
    var list = provider.teams;
    if (_selectedSport != 'All') {
      list = list.where((t) => t.sport == _selectedSport).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) => t.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Future<void> _confirmDelete(BuildContext context, TeamItem team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Remove "${team.name}" from your teams?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppDataProvider>().deleteTeam(team.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final sportFilters = _buildSportFilters(provider);
    final teams = _filteredTeams(provider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search teams...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppCorners.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sportFilters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final sport = sportFilters[index];
                final selected = sport == _selectedSport;
                return FilterChip(
                  label: Text(sport),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedSport = sport),
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppCorners.xl),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: provider.teams.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.groups,
                    imagePath: 'assets/images/empty_teams.png',
                    title: 'No teams yet',
                    subtitle: 'Add your first team to get started',
                    buttonLabel: 'Add Team',
                    onButtonPressed: () =>
                        Navigator.pushNamed(context, '/add-team'),
                  )
                : teams.isEmpty
                    ? Center(
                        child: Text(
                          'No teams match your search',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: teams.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return _TeamCard(
                            team: team,
                            isDark: isDark,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/edit-team',
                              arguments: team,
                            ),
                            onToggleFavorite: () => provider
                                .toggleTeamFavorite(team.id),
                            onDismissed: () =>
                                _confirmDelete(context, team),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_teams',
        onPressed: () => Navigator.pushNamed(context, '/add-team'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamItem team;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDismissed;

  const _TeamCard({
    required this.team,
    required this.isDark,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final teamColor = AppColors.colorFromTag(team.colorTag);
    return Dismissible(
      key: ValueKey(team.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        onDismissed();
        return false;
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppCorners.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: teamColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SportIcon(sport: team.sport, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (team.league != null &&
                          team.league!.isNotEmpty)
                        Text(
                          team.league!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                        ),
                      if (team.notes != null && team.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: AppSpacing.xs),
                          child: Text(
                            team.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    team.isFavorite ? Icons.star : Icons.star_border,
                    color: team.isFavorite
                        ? AppColors.warning
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
