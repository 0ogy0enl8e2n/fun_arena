class PredictionItem {
  final String id;
  final String matchId;
  final String predictedWinner;
  final int confidence;
  final String? reason;
  final String resultStatus;

  const PredictionItem({
    required this.id,
    required this.matchId,
    required this.predictedWinner,
    this.confidence = 3,
    this.reason,
    this.resultStatus = 'pending',
  });

  PredictionItem copyWith({
    String? id,
    String? matchId,
    String? predictedWinner,
    int? confidence,
    String? reason,
    String? resultStatus,
  }) {
    return PredictionItem(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      predictedWinner: predictedWinner ?? this.predictedWinner,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      resultStatus: resultStatus ?? this.resultStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'predictedWinner': predictedWinner,
        'confidence': confidence,
        'reason': reason,
        'resultStatus': resultStatus,
      };

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      predictedWinner: json['predictedWinner'] as String,
      confidence: json['confidence'] as int? ?? 3,
      reason: json['reason'] as String?,
      resultStatus: json['resultStatus'] as String? ?? 'pending',
    );
  }
}
