class Assessment {
  final String id;
  final String userId;
  final String type;
  final Map<String, dynamic> answers;
  final double? riskScore;
  final String? explanation;
  final DateTime createdAt;

  const Assessment({
    required this.id,
    required this.userId,
    required this.type,
    required this.answers,
    required this.createdAt,
    this.riskScore,
    this.explanation,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        answers: (json['answers'] as Map).cast<String, dynamic>(),
        riskScore: (json['risk_score'] as num?)?.toDouble(),
        explanation: json['explanation'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
