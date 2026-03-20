import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/models/team_item.dart';
import 'package:fan_arena/providers/app_provider.dart';

class AddEditTeamScreen extends StatefulWidget {
  const AddEditTeamScreen({super.key});

  @override
  State<AddEditTeamScreen> createState() => _AddEditTeamScreenState();
}

class _AddEditTeamScreenState extends State<AddEditTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _leagueCtrl;
  late TextEditingController _rivalCtrl;
  late TextEditingController _notesCtrl;
  String? _selectedSport;
  String _selectedColor = 'blue';
  bool _isFavorite = false;
  TeamItem? _existingTeam;
  bool _initialized = false;

  bool get _isEditing => _existingTeam != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _leagueCtrl = TextEditingController();
    _rivalCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is TeamItem) {
        _existingTeam = arg;
        _nameCtrl.text = arg.name;
        _selectedSport = arg.sport;
        _selectedColor = arg.colorTag;
        _leagueCtrl.text = arg.league ?? '';
        _rivalCtrl.text = arg.rivalNote ?? '';
        _isFavorite = arg.isFavorite;
        _notesCtrl.text = arg.notes ?? '';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _leagueCtrl.dispose();
    _rivalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppDataProvider>();
    final team = TeamItem(
      id: _existingTeam?.id ?? AppDataProvider.generateId('team'),
      name: _nameCtrl.text.trim(),
      sport: _selectedSport!,
      colorTag: _selectedColor,
      league: _leagueCtrl.text.trim().isEmpty ? null : _leagueCtrl.text.trim(),
      rivalNote:
          _rivalCtrl.text.trim().isEmpty ? null : _rivalCtrl.text.trim(),
      isFavorite: _isFavorite,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (_isEditing) {
      provider.updateTeam(team);
    } else {
      provider.addTeam(team);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existingTeam != null ? 'Team updated' : 'Team added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Remove "${_existingTeam!.name}" permanently?'),
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
      context.read<AppDataProvider>().deleteTeam(_existingTeam!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Team deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Team' : 'Add Team'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Team name *',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Team name is required';
                    }
                    if (v.trim().length < 2) return 'At least 2 characters';
                    if (v.trim().length > 40) return 'Max 40 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  value: _selectedSport,
                  decoration: const InputDecoration(
                    labelText: 'Sport *',
                  ),
                  items: AppConstants.sports
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Icon(
                                  AppConstants.sportIcon(s),
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(s),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSport = v),
                  validator: (v) =>
                      v == null ? 'Please select a sport' : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Color tag',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: List.generate(
                    AppColors.teamColorPresets.length,
                    (i) {
                      final colorName = AppColors.teamColorNames[i];
                      final color = AppColors.teamColorPresets[i];
                      final selected = _selectedColor == colorName;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColor = colorName),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _leagueCtrl,
                  decoration: const InputDecoration(
                    labelText: 'League / Country',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _rivalCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Rival note',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  title: const Text('Favorite team'),
                  value: _isFavorite,
                  onChanged: (v) => setState(() => _isFavorite = v),
                  activeTrackColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppCorners.md),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isEditing ? 'Save Changes' : 'Add Team'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.md),
                    ),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    label: const Text('Delete Team',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppCorners.md),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
