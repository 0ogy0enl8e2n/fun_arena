import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/match_plan.dart';

class AddEditMatchScreen extends StatefulWidget {
  final MatchPlan? match;

  const AddEditMatchScreen({super.key, this.match});

  @override
  State<AddEditMatchScreen> createState() => _AddEditMatchScreenState();
}

class _AddEditMatchScreenState extends State<AddEditMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teamCtrl;
  late final TextEditingController _opponentCtrl;
  late final TextEditingController _tournamentCtrl;
  late final TextEditingController _watchMethodCtrl;
  late final TextEditingController _notesCtrl;

  late String _sport;
  late DateTime _date;
  late TimeOfDay _time;
  late bool _reminderEnabled;
  late int _reminderOffset;

  bool get _isEditing => widget.match != null;

  @override
  void initState() {
    super.initState();
    final m = widget.match;
    _teamCtrl = TextEditingController(text: m?.teamName ?? '');
    _opponentCtrl = TextEditingController(text: m?.opponentName ?? '');
    _tournamentCtrl = TextEditingController(text: m?.tournament ?? '');
    _watchMethodCtrl = TextEditingController(text: m?.watchMethod ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _sport = m?.sport ?? AppConstants.sports.first;
    _date = m != null ? m.dateTime : DateTime.now();
    _time = m != null
        ? TimeOfDay.fromDateTime(m.dateTime)
        : TimeOfDay.now();
    _reminderEnabled = m?.reminderEnabled ?? false;
    _reminderOffset = m?.reminderOffsetMinutes ?? 60;
  }

  @override
  void dispose() {
    _teamCtrl.dispose();
    _opponentCtrl.dispose();
    _tournamentCtrl.dispose();
    _watchMethodCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppDataProvider>();
    final match = MatchPlan(
      id: widget.match?.id ?? AppDataProvider.generateId('match'),
      teamName: _teamCtrl.text.trim(),
      opponentName: _opponentCtrl.text.trim(),
      sport: _sport,
      tournament:
          _tournamentCtrl.text.trim().isEmpty ? null : _tournamentCtrl.text.trim(),
      dateTimeIso: _combinedDateTime.toIso8601String(),
      watchMethod: _watchMethodCtrl.text.trim().isEmpty
          ? null
          : _watchMethodCtrl.text.trim(),
      status: widget.match?.status ?? 'planned',
      reminderEnabled: _reminderEnabled,
      reminderOffsetMinutes: _reminderOffset,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (_isEditing) {
      await provider.updateMatch(match);
    } else {
      await provider.addMatch(match);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Match updated' : 'Match saved'),
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
        title: const Text('Delete Match'),
        content: const Text('This will also remove linked predictions.'),
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
      await context.read<AppDataProvider>().deleteMatch(widget.match!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Match deleted'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Match' : 'Add Match'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete,
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
                  controller: _teamCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Team / Main Side *',
                    prefixIcon: Icon(Icons.shield),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim() == _opponentCtrl.text.trim()) {
                      return 'Cannot be the same as opponent';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _opponentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Opponent *',
                    prefixIcon: Icon(Icons.shield_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim() == _teamCtrl.text.trim()) {
                      return 'Cannot be the same as team';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  value: _sport,
                  decoration: const InputDecoration(
                    labelText: 'Sport *',
                    prefixIcon: Icon(Icons.sports),
                  ),
                  items: AppConstants.sports
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _sport = v);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _tournamentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tournament Name',
                    prefixIcon: Icon(Icons.emoji_events),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _TappableField(
                        label: 'Date *',
                        value: DateFormat('MMM d, yyyy').format(_date),
                        icon: Icons.calendar_today,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _TappableField(
                        label: 'Time *',
                        value: _time.format(context),
                        icon: Icons.access_time,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _watchMethodCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location / Watch Method',
                    prefixIcon: Icon(Icons.tv),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  title: const Text('Reminder'),
                  subtitle: const Text('Get notified before the match'),
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                  contentPadding: EdgeInsets.zero,
                ),
                if (_reminderEnabled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<int>(
                    value: _reminderOffset,
                    decoration: const InputDecoration(
                      labelText: 'Remind me before',
                      prefixIcon: Icon(Icons.alarm),
                    ),
                    items: AppConstants.reminderOffsets.entries
                        .map((e) =>
                            DropdownMenuItem(value: e.value, child: Text(e.key)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _reminderOffset = v);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.check : Icons.add),
                  label: Text(_isEditing ? 'Save Changes' : 'Add Match'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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

class _TappableField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TappableField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppCorners.md),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
