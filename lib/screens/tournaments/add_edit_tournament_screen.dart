import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/tournament_item.dart';

class AddEditTournamentScreen extends StatefulWidget {
  const AddEditTournamentScreen({super.key});

  @override
  State<AddEditTournamentScreen> createState() =>
      _AddEditTournamentScreenState();
}

class _AddEditTournamentScreenState extends State<AddEditTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _seasonCtrl;
  late TextEditingController _participantsCtrl;
  late TextEditingController _notesCtrl;
  String _selectedSport = AppConstants.sports.first;
  bool _isPinned = false;
  TournamentItem? _existing;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _seasonCtrl = TextEditingController();
    _participantsCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is TournamentItem) {
      _existing = args;
      _nameCtrl.text = args.name;
      _selectedSport = args.sport;
      _seasonCtrl.text = args.seasonLabel;
      _participantsCtrl.text = args.favoriteParticipants.join(', ');
      _notesCtrl.text = args.notes ?? '';
      _isPinned = args.isPinned;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _seasonCtrl.dispose();
    _participantsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => _existing != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Tournament' : 'Add Tournament'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: () => _confirmDelete(context, provider),
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
                  decoration: const InputDecoration(
                    labelText: 'Tournament Name',
                    hintText: 'e.g. UEFA Champions League',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'At least 2 characters';
                    if (v.trim().length > 50) return 'Max 50 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  value: _selectedSport,
                  decoration: const InputDecoration(labelText: 'Sport'),
                  items: AppConstants.sports
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Icon(AppConstants.sportIcon(s), size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Text(s),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedSport = v);
                  },
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Sport is required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _seasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Season / Year',
                    hintText: 'e.g. 2025-26',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Season is required';
                    if (v.trim().length < 2) return 'At least 2 characters';
                    if (v.trim().length > 20) return 'Max 20 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _participantsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Favorite Participants',
                    hintText: 'Enter names, comma separated',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes about this tournament',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.sm),

                SwitchListTile(
                  title: const Text('Pin Tournament'),
                  subtitle: const Text('Pinned tournaments appear at the top'),
                  value: _isPinned,
                  onChanged: (v) => setState(() => _isPinned = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.xl),

                FilledButton(
                  onPressed: () => _save(provider),
                  child: Text(_isEditing ? 'Save Changes' : 'Add Tournament'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _parseParticipants() {
    final raw = _participantsCtrl.text;
    if (raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save(AppDataProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final tournament = TournamentItem(
      id: _existing?.id ?? AppDataProvider.generateId('tour'),
      name: _nameCtrl.text.trim(),
      sport: _selectedSport,
      seasonLabel: _seasonCtrl.text.trim(),
      favoriteParticipants: _parseParticipants(),
      isPinned: _isPinned,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (_isEditing) {
      await provider.updateTournament(tournament);
    } else {
      await provider.addTournament(tournament);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tournament saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppDataProvider provider,
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
      await provider.deleteTournament(_existing!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tournament deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
