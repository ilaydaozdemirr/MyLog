// journal_page.dart
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController journalController = TextEditingController();
  final List<String> stickers = [
    '☺️',
    '😍',
    '😢',
    '🤔',
    '😂',
    '😊',
    '❤️',
    '💕',
    '💖',
    '☀️',
    '⭐',
    '🌌',
    '🌟',
    '🌞',
    '☕️',
    '🌋',
    '🌿',
  ];
  final List<Offset> stickerPositions = [];
  final List<String> stickerTypes = [];

  final List<Offset> postItPositions = [];
  final List<String> postItTexts = [];
  final List<bool> postItVisible = [];

  bool isDrawing = false;
  Color selectedColor = Colors.yellow;
  final List<DrawnLine> lines = [];
  List<Offset> currentLine = [];

  DateTime selectedDate = DateTime.now();
  // ✨ Buraya EKLE:
  @override
  void initState() {
    super.initState();
    yukleGunlukVerisi(); // 📥 Günlük verisini bugünkü tarihle yükle
  }

  Future<void> kaydetGunlukVerisi() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = FirebaseFirestore.instance
          .collection('gunluk')
          .doc(uid)
          .collection('gunler')
          .doc(selectedDate.toIso8601String());

      await docRef.set({
        'not': journalController.text,
        'postitler': postItTexts,
        'postitKonumlari':
            postItPositions.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
        'stickerler': stickerTypes,
        'stickerKonumlari':
            stickerPositions.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Journal Saved ✅")));
    } catch (e) {
      debugPrint("Kayıt hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while saving ❌")),
      );
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      await yukleGunlukVerisi();
    }
  }

  void _toggleDrawing() {
    setState(() => isDrawing = !isDrawing);
  }

  void _selectColor(Color color) {
    setState(() => selectedColor = color);
  }

  void _undoDrawing() {
    if (lines.isNotEmpty) setState(() => lines.removeLast());
  }

  void _addPostIt() {
    setState(() {
      postItPositions.add(const Offset(120, 300));
      postItTexts.add("");
      postItVisible.add(true);
    });
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => GridView.builder(
            padding: const EdgeInsets.all(12),
            shrinkWrap: true,
            itemCount: stickers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemBuilder:
                (context, index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      stickerPositions.add(const Offset(100, 200));
                      stickerTypes.add(stickers[index]);
                    });
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      stickers[index],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
          ),
    );
  }

  Future<void> yukleGunlukVerisi() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = FirebaseFirestore.instance
          .collection('gunluk')
          .doc(uid)
          .collection('gunler')
          .doc(selectedDate.toIso8601String());

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() ?? {};

        setState(() {
          journalController.text = data['not'] ?? '';

          final loadedPostItTexts = List<String>.from(data['postitler'] ?? []);
          final loadedPostItPositions = List<Map<String, dynamic>>.from(
            data['postitKonumlari'] ?? [],
          );
          final loadedStickers = List<String>.from(data['stickerler'] ?? []);
          final loadedStickerPositions = List<Map<String, dynamic>>.from(
            data['stickerKonumlari'] ?? [],
          );

          postItTexts
            ..clear()
            ..addAll(loadedPostItTexts);

          postItPositions
            ..clear()
            ..addAll(
              loadedPostItPositions.map(
                (e) => Offset(
                  (e['x'] as num).toDouble(),
                  (e['y'] as num).toDouble(),
                ),
              ),
            );

          postItVisible
            ..clear()
            ..addAll(List<bool>.filled(loadedPostItTexts.length, true));

          stickerTypes
            ..clear()
            ..addAll(loadedStickers);

          stickerPositions
            ..clear()
            ..addAll(
              loadedStickerPositions.map(
                (e) => Offset(
                  (e['x'] as num).toDouble(),
                  (e['y'] as num).toDouble(),
                ),
              ),
            );
        });
      } else {
        setState(() {
          journalController.clear();
          postItTexts.clear();
          postItPositions.clear();
          postItVisible.clear();
          stickerTypes.clear();
          stickerPositions.clear();
        });
      }
    } catch (e) {
      debugPrint('Yükleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(245, 227, 225, 221),
              ),
              child: Text(
                'MYLOG Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.highlight, color: Colors.orange),
              title: const Text('Highlighter'),
              onTap: _toggleDrawing,
            ),
            ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.purple),
              title: const Text('Select Pen Color'),
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:
                              [
                                    Colors.yellow,
                                    Colors.blue,
                                    Colors.pink,
                                    Colors.green,
                                    Colors.red,
                                    Colors.purple,
                                  ]
                                  .map(
                                    (color) => GestureDetector(
                                      onTap: () {
                                        _selectColor(color);
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: color,
                                        radius: 20,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions, color: Colors.pink),
              title: const Text('Add Sticker'),
              onTap: _showStickerPicker,
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2, color: Colors.amber),
              title: const Text('Add Post-it'),
              onTap: _addPostIt,
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text('Home'),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profile'),
              onTap: () {
                // Profil sayfasına yönlendirme işlemi buraya eklenecek
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Text(
              DateFormat.yMMMMd().format(selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            tooltip: 'Kaydet',
            onPressed: kaydetGunlukVerisi,
          ),

          if (isDrawing)
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.red),
              onPressed: _undoDrawing,
              tooltip: 'Geri al',
            ),
        ],
      ),
      body: GestureDetector(
        onPanStart:
            isDrawing
                ? (details) =>
                    setState(() => currentLine = [details.localPosition])
                : null,
        onPanUpdate:
            isDrawing
                ? (details) =>
                    setState(() => currentLine.add(details.localPosition))
                : null,
        onPanEnd:
            isDrawing
                ? (details) => setState(() {
                  lines.add(DrawnLine(List.from(currentLine), selectedColor));
                  currentLine.clear();
                })
                : null,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/notebook_page.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: journalController,
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Write how you felt today here...',
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.8),
                ),
              ),
            ),
            ...stickerPositions.asMap().entries.map((entry) {
              final i = entry.key;
              final offset = entry.value;
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: GestureDetector(
                  onPanUpdate:
                      (details) =>
                          setState(() => stickerPositions[i] += details.delta),
                  child: Text(
                    stickerTypes[i],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),
            ...postItPositions.asMap().entries.map((entry) {
              final i = entry.key;
              final offset = entry.value;
              if (!postItVisible[i]) return const SizedBox.shrink();
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: GestureDetector(
                  onPanUpdate:
                      (details) =>
                          setState(() => postItPositions[i] += details.delta),
                  child: Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.yellow[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown),
                        ),
                        child: TextField(
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: postItTexts[i],
                              selection: TextSelection.collapsed(
                                offset: postItTexts[i].length,
                              ),
                            ),
                          ),
                          onChanged:
                              (val) => setState(() => postItTexts[i] = val),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write a note...',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => postItVisible[i] = false),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            IgnorePointer(
              ignoring: !isDrawing,
              child: CustomPaint(
                painter: HighlighterPainter(
                  lines: lines,
                  currentLine: currentLine,
                  color: selectedColor,
                ),
                size: Size.infinite,
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // AI ile analiz et fonksiyonu
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.insights, color: Colors.white),
                tooltip: 'Analyze with AI',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawnLine {
  final List<Offset> path;
  final Color color;
  DrawnLine(this.path, this.color);
}

class HighlighterPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final List<Offset> currentLine;
  final Color color;
  HighlighterPainter({
    required this.lines,
    required this.currentLine,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint =
          Paint()
            ..color = line.color.withOpacity(0.25)
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 12
            ..isAntiAlias = true;
      for (int i = 0; i < line.path.length - 1; i++) {
        canvas.drawLine(line.path[i], line.path[i + 1], paint);
      }
    }
    final currentPaint =
        Paint()
          ..color = color.withOpacity(0.25)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 12
          ..isAntiAlias = true;
    for (int i = 0; i < currentLine.length - 1; i++) {
      canvas.drawLine(currentLine[i], currentLine[i + 1], currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
