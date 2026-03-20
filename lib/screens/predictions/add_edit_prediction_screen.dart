import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/match_plan.dart';
import 'package:fan_arena/models/prediction_item.dart';

class AddEditPredictionScreen extends StatefulWidget {
  final PredictionItem? prediction;
  final String? matchId;

  const AddEditPredictionScreen({super.key, this.prediction, this.matchId});

  @override
  State<AddEditPredictionScreen> createState() =>
      _AddEditPredictionScreenState();
}

class _AddEditPredictionScreenState extends State<AddEditPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedMatchId;
  late String? _predictedWinner;
  late int _confidence;
  late final TextEditingController _reasonCtrl;
  late String _resultStatus;

  bool get _isEditing => widget.prediction != null;

  @override
  void initState() {
    super.initState();
    final p = widget.prediction;
    _selectedMatchId = p?.matchId ?? widget.matchId;
    _predictedWinner = p?.predictedWinner;
    _confidence = p?.confidence ?? 3;
    _reasonCtrl = TextEditingController(text: p?.reason ?? '');
    _resultStatus = p?.resultStatus ?? 'pending';
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  List<MatchPlan> _availableMatches(AppDataProvider provider) {
    final matchesWithPredictions = provider.predictions
        .map((p) => p.matchId)
        .toSet();
    return provider.matches
        .where((m) => !matchesWithPredictions.contains(m.id))
        .toList();
  }

  MatchPlan? _selectedMatch(AppDataProvider provider) {
    if (_selectedMatchId == null) return null;
    return provider.getMatchById(_selectedMatchId!);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMatchId == null || _predictedWinner == null) return;

    final provider = context.read<AppDataProvider>();
    final prediction = PredictionItem(
      id: widget.prediction?.id ?? AppDataProvider.generateId('pred'),
      matchId: _selectedMatchId!,
      predictedWinner: _predictedWinner!,
      confidence: _confidence,
      reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      resultStatus: _resultStatus,
    );

    if (_isEditing) {
      await provider.updatePrediction(prediction);
    } else {
      await provider.addPrediction(prediction);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prediction saved'),
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
        title: const Text('Delete Prediction'),
        content:
            const Text('Are you sure you want to delete this prediction?'),
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
      await context
          .read<AppDataProvider>()
          .deletePrediction(widget.prediction!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Prediction deleted'),
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
    final provider = context.watch<AppDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final match = _selectedMatch(provider);
    final hasFixedMatch = widget.matchId != null || _isEditing;

    final winnerOptions = match != null
        ? [match.teamName, match.opponentName]
        : <String>[];

    if (_predictedWinner != null && !winnerOptions.contains(_predictedWinner)) {
      _predictedWinner = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Prediction' : 'Add Prediction'),
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
                if (hasFixedMatch && match != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.md),
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.sports),
                      title: Text(
                        '${match.teamName} vs ${match.opponentName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(match.sport),
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    value: _selectedMatchId,
                    decoration: const InputDecoration(
                      labelText: 'Select Match *',
                      prefixIcon: Icon(Icons.sports),
                    ),
                    items: _availableMatches(provider).map((m) {
                      return DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          '${m.teamName} vs ${m.opponentName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedMatchId = v;
                        _predictedWinner = null;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Please select a match' : null,
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  value: _predictedWinner,
                  decoration: const InputDecoration(
                    labelText: 'Predicted Winner *',
                    prefixIcon: Icon(Icons.emoji_events),
                  ),
                  items: winnerOptions
                      .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                      .toList(),
                  onChanged: (v) => setState(() => _predictedWinner = v),
                  validator: (v) =>
                      v == null ? 'Please select a winner' : null,
                ),

                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Confidence',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.sentiment_dissatisfied, size: 20),
                    Expanded(
                      child: Slider(
                        value: _confidence.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _confidenceLabel(_confidence),
                        onChanged: (v) =>
                            setState(() => _confidence = v.round()),
                      ),
                    ),
                    const Icon(Icons.sentiment_very_satisfied, size: 20),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < _confidence ? Icons.star : Icons.star_border,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                TextFormField(
                  controller: _reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reasoning',
                    prefixIcon: Icon(Icons.lightbulb_outline),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: 250,
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Result Status',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String>(
                  segments: AppConstants.predictionStatuses.map((s) {
                    return ButtonSegment(
                      value: s,
                      label: Text(AppConstants.predictionStatusLabel(s)),
                      icon: Icon(
                        s == 'pending'
                            ? Icons.hourglass_empty
                            : s == 'correct'
                                ? Icons.check_circle
                                : Icons.cancel,
                        size: 18,
                      ),
                    );
                  }).toList(),
                  selected: {_resultStatus},
                  onSelectionChanged: (v) =>
                      setState(() => _resultStatus = v.first),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                FilledButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.check : Icons.add),
                  label:
                      Text(_isEditing ? 'Save Changes' : 'Add Prediction'),
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

  String _confidenceLabel(int value) {
    return switch (value) {
      1 => 'Very Low',
      2 => 'Low',
      3 => 'Medium',
      4 => 'High',
      5 => 'Very High',
      _ => '',
    };
  }
}
