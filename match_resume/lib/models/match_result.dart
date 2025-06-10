class MatchResult {
  final List<String> missing;
  final Map<String, double> pieChartPercentages;
  final double similarityScore;

  MatchResult({
    required this.missing,
    required this.pieChartPercentages,
    required this.similarityScore,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    final apiPieChart = Map<String, dynamic>.from(json['pie_chart_percentages'] ?? {});
    
    double safeDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    final renamedPieChart = {
      "Matched": safeDouble(apiPieChart["matched_percent"]),
      "Missing": safeDouble(apiPieChart["missing_percent"]),
      "Extra": safeDouble(apiPieChart["extra_percent"]),
      "Unrecognized": safeDouble(apiPieChart["unrecognized_percent"]),
    };

    return MatchResult(
      missing: List<String>.from(json['missing'] ?? []),
      pieChartPercentages: renamedPieChart,
      similarityScore: safeDouble(json['similarity_score']),
    );
  }
}
