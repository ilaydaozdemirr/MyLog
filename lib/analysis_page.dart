import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  DateTimeRange? selectedRange;
  Map<String, int> categoryCounts = {};
  bool isLoading = false;

  int usageDayCount = 0;
  int totalDayCount = 0;
  double usagePercent = 0.0;
  double productivityScore = 0.0;

  double calculateProductivityScore({
    required int checkedTasks,
    required int totalTasks,
    required int postIts,
    required int stickers,
    required int totalDays,
    required int journalDays,
    required int agendaUsedDays,
  }) {
    const taskWeight = 3.0;
    const postItWeight = 0.5;
    const stickerWeight = 0.5;
    const journalWeight = 3.0;
    const missedAgendaPenalty = -1.5;
    const missedJournalPenalty = -1.0;

    final actualScore =
        (checkedTasks * taskWeight) +
        (postIts * postItWeight) +
        (stickers * stickerWeight) +
        (journalDays * journalWeight) +
        ((totalDays - agendaUsedDays) * missedAgendaPenalty) +
        ((totalDays - journalDays) * missedJournalPenalty);

    final maxScore =
        (totalTasks * taskWeight) +
        (postIts * postItWeight) +
        (stickers * stickerWeight) +
        (totalDays * journalWeight);

    if (maxScore <= 0) return 0;

    return (actualScore / maxScore).clamp(0.0, 1.0) * 100;
  }

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
  }

  Future<void> _fetchAgendaUsage() async {
    if (selectedRange == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('ajanda')
            .doc(uid)
            .collection('gunler')
            .get();

    final start = selectedRange!.start;
    final end = selectedRange!.end;
    totalDayCount = end.difference(start).inDays + 1;

    usageDayCount = 0;

    for (int i = 0; i < totalDayCount; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final dayPrefix = date.toIso8601String().split("T").first;

      final found = snapshot.docs.any((doc) => doc.id.startsWith(dayPrefix));
      if (found) usageDayCount++;
    }

    usagePercent = usageDayCount / totalDayCount;

    setState(() {});
  }

  Future<void> fetchAllAnalysisData() async {
    setState(() {
      isLoading = true;
      categoryCounts.clear();
    });

    await _fetchCategoryData(); // Kategori verisi çek
    await _fetchAgendaUsage(); // Ajanda kullanım oranı hesapla
    await _fetchProductivityScore();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchProductivityScore() async {
    if (selectedRange == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final start = selectedRange!.start;
    final end = selectedRange!.end;

    int totalCheckedTasks = 0;
    int totalTasks = 0;
    int totalPostIts = 0;
    int totalStickers = 0;
    int journalDays = 0;

    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final dayStr = date.toIso8601String().split("T").first;

      // 🔹 Ajanda verisi
      final ajandaSnapshot =
          await FirebaseFirestore.instance
              .collection('ajanda')
              .doc(uid)
              .collection('gunler')
              .where(FieldPath.documentId, isGreaterThanOrEqualTo: dayStr)
              .where(FieldPath.documentId, isLessThan: '$dayStr' + 'T23:59:59')
              .get();

      for (final doc in ajandaSnapshot.docs) {
        final data = doc.data();
        final checkedList = (data['checked'] as List?)?.cast<bool>() ?? [];
        final checked = checkedList.where((t) => t == true).length;

        totalCheckedTasks += checked;
        totalTasks += checkedList.length;
        totalPostIts += (data['postitler'] as List?)?.length ?? 0;
        totalStickers += (data['stickerKonumlari'] as List?)?.length ?? 0;
      }

      // 🔹 Günlük verisi
      final journalSnapshot =
          await FirebaseFirestore.instance
              .collection('gunluk')
              .doc(uid)
              .collection('gunler')
              .where(FieldPath.documentId, isGreaterThanOrEqualTo: dayStr)
              .where(FieldPath.documentId, isLessThan: '$dayStr' + 'T23:59:59')
              .get();

      if (journalSnapshot.docs.isNotEmpty) {
        journalDays++;
      }
    }

    final score = calculateProductivityScore(
      checkedTasks: totalCheckedTasks,
      totalTasks: totalTasks,
      postIts: totalPostIts,
      stickers: totalStickers,
      totalDays: totalDayCount,
      journalDays: journalDays,
      agendaUsedDays: usageDayCount,
    );

    setState(() {
      productivityScore = score;
    });
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final end = now;
    selectedRange = DateTimeRange(start: start, end: end);
    fetchAllAnalysisData();
  }

  Future<void> _fetchCategoryData() async {
    if (selectedRange == null) return;

    setState(() {
      isLoading = true;
      categoryCounts.clear();
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('ajanda')
            .doc(uid)
            .collection('gunler')
            .where(
              FieldPath.documentId,
              isGreaterThanOrEqualTo: selectedRange!.start.toIso8601String(),
            )
            .where(
              FieldPath.documentId,
              isLessThanOrEqualTo: selectedRange!.end.toIso8601String(),
            )
            .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final kategoriler = List<String>.from(data['kategoriler'] ?? []);
      for (final kategori in kategoriler) {
        categoryCounts[kategori] = (categoryCounts[kategori] ?? 0) + 1;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
      _fetchCategoryData();
      fetchAllAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Analysis'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 244, 242, 242),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAgendaUsageCard(),
                  const SizedBox(height: 20),
                  _buildPieChartCard(),
                  const SizedBox(height: 20),
                  _buildProductivityCard(),
                ],
              ),
    );
  }

  Widget _buildAgendaUsageCard() {
    return Card(
      color: const Color(0xFFFDFDFD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20), // 👈 Pie chart ile aynı
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📅 Agenda Usage Rate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 10.0,
                  percent: usagePercent.clamp(0.0, 1.0),
                  center: Text('${(usagePercent * 100).toStringAsFixed(1)}%'),
                  progressColor: Colors.green,
                  backgroundColor: Colors.grey.shade300,
                  animation: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "$usageDayCount out of $totalDayCount days used",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityCard() {
    return Card(
      color: const Color(0xFFFDFDFD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🚀 Productivity Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 10.0,
              percent: productivityScore.clamp(0.0, 100.0) / 100,
              center: Text('${productivityScore.toStringAsFixed(1)}%'),
              progressColor: Colors.deepPurple,
              backgroundColor: Colors.grey.shade300,
              animation: true,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (productivityScore < 50)
                  const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                    size: 28,
                  )
                else if (productivityScore < 70)
                  const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.orange,
                    size: 28,
                  )
                else
                  const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                    size: 28,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    getProductivityMessage(productivityScore),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    final total = categoryCounts.values.fold(0, (a, b) => a + b);
    final List<PieChartSectionData> sections = [];

    categoryCounts.forEach((key, value) {
      final percentage = value / total * 100;
      final color = _getRandomColor(key.hashCode);

      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',

          color: color,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return Card(
      color: const Color(0xFFFDFDFD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '📊 Category Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(sections: sections, centerSpaceRadius: 40),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children:
                  categoryCounts.keys.map((key) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: _getRandomColor(key.hashCode),
                        ),
                        const SizedBox(width: 4),
                        Text(key),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRandomColor(int seed) {
    final rnd = Random(seed);
    return Color.fromARGB(
      255,
      rnd.nextInt(200),
      rnd.nextInt(200),
      rnd.nextInt(200),
    );
  }

  String getProductivityMessage(double score) {
    if (score < 50) {
      return "🔴 Keep pushing! Even small steps matter. Don't give up!";
    } else if (score < 70) {
      return "🟡 Not bad! With a bit more effort, you'll reach your goals!";
    } else {
      return "🟢 Amazing work! Keep up the great momentum!";
    }
  }
}
