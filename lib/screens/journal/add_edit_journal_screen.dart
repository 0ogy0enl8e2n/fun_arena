import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/journal_entry.dart';

class AddEditJournalScreen extends StatefulWidget {
  const AddEditJournalScreen({super.key});

  @override
  State<AddEditJournalScreen> createState() => _AddEditJournalScreenState();
}

class _AddEditJournalScreenState extends State<AddEditJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  late DateTime _selectedDate;
  String? _selectedTeamId;
  String? _selectedMatchId;
  String _selectedMood = 'Neutral';
  JournalEntry? _existing;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is JournalEntry) {
      _existing = args;
      _titleCtrl.text = args.title;
      _bodyCtrl.text = args.body;
      _selectedDate = args.date;
      _selectedTeamId = args.teamId;
      _selectedMatchId = args.matchId;
      _selectedMood = args.mood;
    } else if (args is Map<String, dynamic>) {
      _selectedTeamId = args['teamId'] as String?;
      _selectedMatchId = args['matchId'] as String?;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => _existing != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Add Entry'),
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
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Give your entry a title',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Title is required';
                    if (v.trim().length < 2) return 'At least 2 characters';
                    if (v.trim().length > 60) return 'Max 60 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        hintText: DateFormat('MMM d, yyyy').format(_selectedDate),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('MMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  value: _selectedTeamId,
                  decoration: const InputDecoration(labelText: 'Linked Team'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...provider.teams.map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedTeamId = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  value: _selectedMatchId,
                  decoration: const InputDecoration(labelText: 'Linked Match'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...provider.matches.map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text('${m.teamName} vs ${m.opponentName}'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedMatchId = v),
                ),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Mood',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AppConstants.moods.map((mood) {
                    final isSelected = _selectedMood == mood;
                    final color = AppConstants.moodColor(mood);
                    return ChoiceChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppConstants.moodIcon(mood),
                            size: 16,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(mood),
                        ],
                      ),
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                      onSelected: (_) => setState(() => _selectedMood = mood),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _bodyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Entry',
                    hintText: 'Write about your match-day experience...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Entry body is required';
                    if (v.trim().length < 10) return 'At least 10 characters';
                    if (v.trim().length > 1000) return 'Max 1000 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                FilledButton(
                  onPressed: () => _save(provider),
                  child: Text(_isEditing ? 'Save Changes' : 'Add Entry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save(AppDataProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final entry = JournalEntry(
      id: _existing?.id ?? AppDataProvider.generateId('journal'),
      title: _titleCtrl.text.trim(),
      dateIso: _selectedDate.toIso8601String(),
      teamId: _selectedTeamId,
      matchId: _selectedMatchId,
      mood: _selectedMood,
      body: _bodyCtrl.text.trim(),
    );

    if (_isEditing) {
      await provider.updateJournalEntry(entry);
    } else {
      await provider.addJournalEntry(entry);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Journal entry saved'),
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
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await provider.deleteJournalEntry(_existing!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Entry deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
