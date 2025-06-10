import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../widgets/awesome_warning_snackbar.dart';
import '../models/match_result.dart';
import '../services/match_services.dart';
import 'result_page.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final TextEditingController _jobDescController = TextEditingController();
  File? _selectedFile;
  bool _loading = false;

  Future<void> _pickFile() async {
    FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (picked != null) {
      setState(() => _selectedFile = File(picked.files.single.path!));
    }
  }

  Future<void> _submit() async {
    final text = _jobDescController.text.trim();
    if (text.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a job description and select a file'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      MatchResult res = await matchService.postResumeMatch(
        jobDescription: text,
        resumeFile: _selectedFile!,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultPage(result: res)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _jobDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canSubmit =
        _jobDescController.text.trim().isNotEmpty && _selectedFile != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Resume Matcher")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Job Description TextField
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _jobDescController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration.collapsed(
                    hintText: "Enter job description here...",
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // File Picker Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Resume"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedFile?.path.split(Platform.pathSeparator).last ??
                        "No file selected",
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Submit Button
            // ...existing code...
            GestureDetector(
              onTap: () {
                if (!_loading && !canSubmit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    awesomeWarningSnackbar(
                      title: 'Fields Required',
                      message:
                          'Please provide a job description and select a file.',
                    ),
                  );
                }
              },
              child: AbsorbPointer(
                absorbing: _loading || !canSubmit,
                child: ElevatedButton(
                  onPressed: _loading || !canSubmit ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800], // Set to nav bar blue
                    foregroundColor: Colors.white, // Set font color to white
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Submit & Analyze",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white), // Ensure text is white
                        ),
                ),
              ),
            ),
// ...existing code...
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
