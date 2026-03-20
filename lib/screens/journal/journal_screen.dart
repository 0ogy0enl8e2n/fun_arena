import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/journal_entry.dart';
import 'package:fan_arena/widgets/empty_state_widget.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _selectedMood = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allEntries = List<JournalEntry>.from(provider.journalEntries)
      ..sort((a, b) => b.dateIso.compareTo(a.dateIso));

    final filteredEntries = _selectedMood == 'All'
        ? allEntries
        : allEntries.where((e) => e.mood == _selectedMood).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Fan Journal')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _MoodFilterChip(
                  label: 'All',
                  isSelected: _selectedMood == 'All',
                  onTap: () => setState(() => _selectedMood = 'All'),
                ),
                ...AppConstants.moods.map(
                  (mood) => _MoodFilterChip(
                    label: mood,
                    icon: AppConstants.moodIcon(mood),
                    color: AppConstants.moodColor(mood),
                    isSelected: _selectedMood == mood,
                    onTap: () => setState(() => _selectedMood = mood),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredEntries.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.book,
                    imagePath: 'assets/images/empty_journal.png',
                    title: 'Your fan journal is empty',
                    subtitle:
                        'Record your match-day memories and reactions',
                    buttonLabel: 'Add Entry',
                    onButtonPressed: () =>
                        Navigator.pushNamed(context, '/add-journal'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return _JournalCard(
                        entry: entry,
                        provider: provider,
                        isDark: isDark,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/edit-journal',
                          arguments: entry,
                        ),
                        onDismissed: () => _confirmDelete(context, provider, entry),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_journal',
        onPressed: () => Navigator.pushNamed(context, '/add-journal'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppDataProvider provider,
    JournalEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
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
    if (confirmed == true && mounted) {
      await provider.deleteJournalEntry(entry.id);
    }
  }
}

class _MoodFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodFilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label),
          ],
        ),
        onSelected: (_) => onTap(),
        selectedColor: color ?? AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final AppDataProvider provider;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _JournalCard({
    required this.entry,
    required this.provider,
    required this.isDark,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMM d, yyyy').format(entry.date);
    final moodColor = AppConstants.moodColor(entry.mood);
    final moodIconData = AppConstants.moodIcon(entry.mood);
    final team = entry.teamId != null ? provider.getTeamById(entry.teamId!) : null;

    return Dismissible(
      key: ValueKey(entry.id),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: moodColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppCorners.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(moodIconData, size: 14, color: moodColor),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            entry.mood,
                            style: TextStyle(
                              fontSize: 12,
                              color: moodColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (team != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.groups,
                        size: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        team.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  entry.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
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
