import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/match_result.dart';

class ResultPage extends StatefulWidget {
  final MatchResult result;
  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0, end: widget.result.similarityScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Similarity Score Title
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Similarity Score",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Similarity Score Card with Donut Chart
            Card(
              elevation: 0,
              color: surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      dataMap: widget.result.pieChartPercentages,
                      chartType: ChartType.ring,
                      chartRadius: MediaQuery.of(context).size.width / 1.5,
                      ringStrokeWidth: 36,
                      legendOptions: const LegendOptions(
                        showLegendsInRow: false,
                        legendPosition: LegendPosition.bottom,
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValues: false,
                        showChartValuesInPercentage: false,
                      ),
                      baseChartColor: theme.colorScheme.background,
                      colorList: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                        Colors.green[400]!,
                        Colors.red[400]!,
                      ],
                      animationDuration: const Duration(milliseconds: 1800),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.width / 1.5,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Text(
                            _animation.value.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 80,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              color: primary,
                              shadows: [
                                Shadow(
                                  offset: const Offset(3, 3),
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Missing Keywords:",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Missing Keywords Card
            Card(
              elevation: 0,
              color: Colors.grey[10],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.result.missing.isEmpty)
                      Text(
                        "None! Great job.",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.result.missing
                            .map<Widget>((e) => Chip(
                                  label: Text(
                                    e,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 5, 5, 5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.white),
                                  ),
                                  elevation: 0,
                                  shadowColor:
                                      const Color.fromARGB(255, 100, 97, 97),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}