import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/models/prediction_item.dart';
import 'package:fan_arena/widgets/empty_state_widget.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  String _filter = 'all';

  static const _filters = ['all', 'pending', 'correct', 'incorrect'];
  static const _filterLabels = {
    'all': 'All',
    'pending': 'Pending',
    'correct': 'Correct',
    'incorrect': 'Incorrect',
  };

  List<PredictionItem> _applyFilter(List<PredictionItem> predictions) {
    if (_filter == 'all') return predictions;
    return predictions.where((p) => p.resultStatus == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final predictions = _applyFilter(provider.predictions);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Predictions')),
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
            child: predictions.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.psychology,
                    imagePath: 'assets/images/empty_predictions.png',
                    title: 'No predictions yet',
                    subtitle: 'Make predictions for your saved matches',
                    buttonLabel: 'Go to Planner',
                    onButtonPressed: () =>
                        Navigator.pushNamed(context, '/planner'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: predictions.length,
                    itemBuilder: (context, index) => _PredictionCard(
                      prediction: predictions[index],
                      provider: provider,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionItem prediction;
  final AppDataProvider provider;

  const _PredictionCard({
    required this.prediction,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final match = provider.getMatchById(prediction.matchId);
    final matchTitle = match != null
        ? '${match.teamName} vs ${match.opponentName}'
        : 'Unknown Match';
    final statusColor =
        AppConstants.predictionStatusColor(prediction.resultStatus);
    final statusLabel =
        AppConstants.predictionStatusLabel(prediction.resultStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.md),
        onTap: () => Navigator.pushNamed(context, '/edit-prediction',
            arguments: prediction),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      matchTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
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
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.emoji_events,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    prediction.predictedWinner,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < prediction.confidence
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              if (prediction.reason != null &&
                  prediction.reason!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  prediction.reason!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
