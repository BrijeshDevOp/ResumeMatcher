import 'dart:io';
import '../models/match_result.dart';

abstract class MatchServiceInterface {
  Future<MatchResult> postResumeMatch({
    required String jobDescription,
    required File resumeFile,
  });
}

