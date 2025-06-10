import 'package:flutter/material.dart';
import 'pages/match_page.dart';

void main() {
  runApp(const ResumeMatcherApp());
}

class ResumeMatcherApp extends StatelessWidget {
  const ResumeMatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Resume Matcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue[800]!,
          secondary: Colors.amber[600]!,
          surface: Colors.white,
          background: Color(0xFFF5F5F5),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const MatchPage(),
    );
  }
}
