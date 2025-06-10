import 'dart:io';
import 'dart:async';
import '../models/match_result.dart';
import 'match_service_interface.dart';

class DummyMatchService implements MatchServiceInterface {
  @override
  Future<MatchResult> postResumeMatch({
    required String jobDescription,
    required File resumeFile,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Rename the keys for display
    final renamedPieChartPercentages = {
      "Matched": 50.0,
      "Missing": 30.0,
      "Extra": 12.0,
      "Unrecognized": 8.0,
    };

    // Return fixed dummy data
    return MatchResult(
      missing: [
        "healthcare management",
        "restful apis",
        "continuous deployment",
        "css",
        "azure",
        "databases",
        "aws",
        "problem-solving",
        "python (django, flask)",
        "knowledge representation",
        "mysql",
        "transportation engineering",
        "html",
        "educational technology",
        "instruction",
        "javascript",
        "team operations",
        "job satisfaction",
        "postgresql",
        "cloud services"
      ],
      pieChartPercentages: renamedPieChartPercentages,
      similarityScore: 50,
    );
  }
}
