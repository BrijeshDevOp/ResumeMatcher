import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_result.dart';
import 'match_service_interface.dart';

class RealMatchService implements MatchServiceInterface {
  // final String apiUrl = 'http://192.168.14.1:8000/match/'; // USB debugging
  // final String apiUrl = 'http://127.0.0.1:8000/match/'; // Local Web
  final String apiUrl = 'http://10.0.2.2:8000/match/'; //Emulator

  @override
  Future<MatchResult> postResumeMatch({
    required String jobDescription,
    required File resumeFile,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['job_description'] = jobDescription;
    request.files
        .add(await http.MultipartFile.fromPath('resume', resumeFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return MatchResult.fromJson(
          jsonData); // Delegates all parsing/renaming to model
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
