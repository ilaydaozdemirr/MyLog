import 'package:flutter/material.dart';
import 'ai/ai_service_web.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'history_page.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class JournalWebPage extends StatefulWidget {
  const JournalWebPage({super.key});

  @override
  State<JournalWebPage> createState() => _JournalWebPageState();
}

const Color koyuMor = Color(0xFF24143F);

class _JournalWebPageState extends State<JournalWebPage> {
  final TextEditingController journalController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

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
    '✨',
    '🔥',
    '🎯',

    '🌈',
    '🎵',
    '🎨',
    '🍀',
    '🍕',
    '☕',
    '🍰',
    '🌍',
    '🪐',
    '🧸',
    '🎈',
    '🚀',
    '🌸',
    '🌻',
    '🌙',
    '🌟',
    '👑',
    '🐾',
    '🍂',
    '💬',
    '💡',
    '⚡',
    '🎂',
    '🖋️',
    '🎁',
    '📚',
    '🏆',
    '💻',
    '🧠',
    '🧳',
  ];
  final List<Offset> stickerPositions = [];
  final List<String> stickerTypes = [];

  final List<Offset> postItPositions = [];
  final List<String> postItTexts = [];
  final List<bool> postItVisible = [];
  String? hoveredItem;
  String? hoveredLabel;

  bool isDrawing = false;
  Color selectedColor = Colors.yellow;
  final List<DrawnLine> lines = [];
  List<Offset> currentLine = [];

  DateTime selectedDate = DateTime.now();
  String _aiAnaliz = '';

  Future<void> _analyzeWithAI() async {
    final text = journalController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to analyze.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // AI'den analiz al
    _aiAnaliz = await AIServiceWeb.analyzeText(text);

    Navigator.of(context).pop();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final date = selectedDate.toIso8601String();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('analyses')
        .doc(date)
        .set({
          'analysis': _aiAnaliz,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Sonucu göster
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('AI Mood Analysis'),
            content: SingleChildScrollView(child: Text(_aiAnaliz)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    yukleGunlukVerisi(); // 📥 Günlük verisini bugünkü tarihle yükle
  }

  Drawer buildModernWebDrawer(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'MYLOG Menu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                _buildDrawerItem(
                  icon: Icons.history,
                  label: 'AI Analiz Geçmişi',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      ),
                ),
                _buildDrawerItem(
                  icon: Icons.highlight,
                  label: 'Highlighter',
                  onTap: _toggleDrawing,
                ),
                _buildDrawerItem(
                  icon: Icons.color_lens,
                  label: 'Select Pen Color',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:
                                [
                                  const Color.fromARGB(255, 255, 244, 141),
                                  const Color.fromARGB(255, 195, 228, 255),
                                  const Color.fromARGB(255, 255, 192, 213),
                                  const Color.fromARGB(255, 58, 255, 65),
                                  const Color.fromARGB(255, 247, 175, 170),
                                  const Color.fromARGB(255, 181, 159, 185),
                                  const Color.fromARGB(255, 214, 197, 254),
                                  const Color.fromARGB(255, 175, 212, 255),
                                ].map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      _selectColor(color);
                                      Navigator.pop(context);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 20,
                                    ),
                                  );
                                }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.emoji_emotions,
                  label: 'Add Sticker',
                  onTap: _showStickerPicker,
                ),
                _buildDrawerItem(
                  icon: Icons.sticky_note_2,
                  label: 'Add Post-it',
                  onTap: _addPostIt,
                ),
                _buildDrawerItem(
                  icon: Icons.home,
                  label: 'Home',
                  onTap: () => Navigator.pushNamed(context, '/home'),
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => hoveredLabel = label);
      },
      onExit: (_) {
        setState(() => hoveredLabel = null);
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          color:
              hoveredLabel == label
                  ? koyuMor.withOpacity(0.08)
                  : Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: hoveredLabel == label ? Colors.white : koyuMor,
            ),
            title: Text(
              label,
              style: TextStyle(
                color: hoveredLabel == label ? Colors.white : koyuMor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
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
        'ai_analiz': _aiAnaliz,
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
      backgroundColor: const Color.fromARGB(245, 227, 225, 221),
      drawer: buildModernWebDrawer(context),

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
            Center(
              child: Container(
                width: 800,
                height: 1130,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('web/assets/notebook_pagee.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: TextField(
                    controller: journalController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write how you felt today here...',
                    ),
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
            ),

            //  Stickers
            ...stickerPositions.asMap().entries.map((entry) {
              final i = entry.key;
              final offset = entry.value;
              return Positioned(
                left: offset.dx,
                top: offset.dy - _scrollOffset,
                child: GestureDetector(
                  onPanUpdate:
                      (details) =>
                          setState(() => stickerPositions[i] += details.delta),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Remove Sticker"),
                            content: const Text(
                              "Do you want to delete this sticker?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    stickerPositions.removeAt(i);
                                    stickerTypes.removeAt(i);
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Text(
                    stickerTypes[i],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),

            // ✅ Post-it
            ...postItPositions.asMap().entries.map((entry) {
              final i = entry.key;
              final offset = entry.value;
              if (!postItVisible[i]) return const SizedBox.shrink();
              final controller = TextEditingController(text: postItTexts[i]);
              return Positioned(
                left: offset.dx,
                top: offset.dy - _scrollOffset,
                child: GestureDetector(
                  onPanUpdate:
                      (details) =>
                          setState(() => postItPositions[i] += details.delta),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Remove Post-it"),
                            content: const Text(
                              "Do you want to delete this post-it?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    postItTexts.removeAt(i);
                                    postItPositions.removeAt(i);
                                    postItVisible.removeAt(i);
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown),
                    ),
                    child: TextField(
                      controller: controller,
                      onChanged: (val) => setState(() => postItTexts[i] = val),
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write a note...',
                      ),
                    ),
                  ),
                ),
              );
            }),

            //  Highlighter çizim alanı
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

            // Analyze butonu
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _analyzeWithAI,
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
