class ClassifierService {
  // Very simple, local heuristics for MVP. Replace with on-device ML models later.
  // Returns a risk score [0..1] and an explanation string.
  Map<String, dynamic> stressScore({required int sleepQuality, required int mood, required int workload}) {
    // All scales 1..5. Higher workload and lower sleep/mood increase risk.
    final sleepFactor = (6 - sleepQuality) / 5.0; // poor sleep -> higher
    final moodFactor = (6 - mood) / 5.0; // worse mood -> higher
    final workloadFactor = workload / 5.0; // heavier workload -> higher
    final score = (sleepFactor * 0.4 + moodFactor * 0.4 + workloadFactor * 0.2).clamp(0.0, 1.0);
    return {
      'score': score,
      'explanation': 'Computed from sleep(${sleepQuality}), mood(${mood}), workload(${workload}).'
    };
  }

  Map<String, dynamic> breastRiskHeuristic({required int age, required bool familyHistory}) {
    double score = 0.1;
    if (age >= 40) score += 0.3;
    if (age >= 50) score += 0.2;
    if (familyHistory) score += 0.3;
    score = score.clamp(0.0, 1.0);
    return {
      'score': score,
      'explanation': 'Age and family history heuristic (non-diagnostic).'
    };
  }

  Map<String, dynamic> cervicalRiskHeuristic({required int age, required bool screeningUpToDate}) {
    double score = 0.2;
    if (age >= 25 && age <= 65 && !screeningUpToDate) score += 0.3;
    if (age > 65 && !screeningUpToDate) score += 0.2;
    score = score.clamp(0.0, 1.0);
    return {
      'score': score,
      'explanation': 'Age bracket and screening recency heuristic (non-diagnostic).'
    };
  }

  Map<String, dynamic> osteoporosisRiskHeuristic({required int age, required bool lowBmi}) {
    double score = 0.1;
    if (age >= 50) score += 0.3;
    if (age >= 65) score += 0.2;
    if (lowBmi) score += 0.2;
    score = score.clamp(0.0, 1.0);
    return {
      'score': score,
      'explanation': 'Age and BMI heuristic (non-diagnostic).'
    };
  }
}
