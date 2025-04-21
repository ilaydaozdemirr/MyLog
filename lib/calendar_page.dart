import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();
  final List<String> todos = [];
  final List<bool> todosChecked = [];
  final List<String> todoKategorileri = [];
  String? secilenKategori;

  final List<String> kategoriler = [
    'İş',
    'Okul',
    'Spor',
    'Kişisel',
    'Sağlık',
    'Alışveriş',
  ];
  final List<String> stickers = [
    '☀️',
    '⭐',
    '🌿',
    '📌',
    '😊',
    '😢',
    '❤️',
    '✨',
    '🔥',
    '🎯',
  ];
  final List<Offset> stickerPositions = [];
  final List<String> stickerTypes = [];
  final List<Offset> postItPositions = [];
  final List<String> postItTexts = [];
  final List<bool> postItVisible = [];
  final TextEditingController todoController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isDrawing = false;
  Color selectedColor = Colors.yellow;
  final List<DrawnLine> lines = [];
  List<Offset> currentLine = [];
  Future<void> kaydetAjandaVerisi() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final docRef = FirebaseFirestore.instance
          .collection('ajanda')
          .doc(uid)
          .collection('gunler')
          .doc(selectedDate.toIso8601String());

      await docRef.set({
        'todos': todos,
        'notlar': notesController.text,
        'postitler': postItTexts,
        'postitKonumlari':
            postItPositions.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      });
    } catch (e) {
      debugPrint("🔥 Kayıt sırasında hata: $e");
    }
  }

  Future<void> yukleAjandaVerisi() async {
    Future<void> kaydetAjandaVerisi() async {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        final docRef = FirebaseFirestore.instance
            .collection('ajanda')
            .doc(uid)
            .collection('gunler')
            .doc(selectedDate.toIso8601String());

        await docRef.set({
          'todos': todos,
          'checked': todosChecked,
          'notlar': notesController.text,
          'postitler': postItTexts,
          'postitKonumlari':
              postItPositions.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
        });
      } catch (e) {
        debugPrint("🔥 Kayıt sırasında hata: $e");
      }
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('ajanda')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('gunler')
          .doc(selectedDate.toIso8601String());

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() ?? {};

        final List<String> loadedTodos = List<String>.from(data['todos'] ?? []);

        final List<bool> loadedChecked =
            data['checked'] != null
                ? List<bool>.from(data['checked'])
                : <bool>[];
        final List<String> loadedKategoriler = List<String>.from(
          data['kategoriler'] ?? [],
        );
        final List<String> loadedPostItTexts = List<String>.from(
          data['postitler'] ?? [],
        );
        final List<Map<String, dynamic>> loadedPostItPositions =
            List<Map<String, dynamic>>.from(data['postitKonumlari'] ?? []);

        setState(() {
          todos.clear();
          todos.addAll(loadedTodos);

          todosChecked.clear();
          todosChecked.addAll(
            (loadedChecked.length == loadedTodos.length)
                ? loadedChecked
                : List<bool>.filled(loadedTodos.length, false),
          );

          notesController.text = data['notlar'] ?? '';

          postItTexts.clear();
          postItTexts.addAll(loadedPostItTexts);

          postItPositions.clear();
          postItPositions.addAll(
            loadedPostItPositions.map((e) {
              final double x = (e['x'] as num).toDouble();
              final double y = (e['y'] as num).toDouble();
              return Offset(x, y);
            }),
          );

          postItVisible.clear();
          postItVisible.addAll(
            List<bool>.filled(loadedPostItTexts.length, true),
          );
        });
      } else {
        _resetAjandaVerisi();
      }
    } catch (e) {
      debugPrint("[AJANDA] Veri yüklenirken hata oluştu: $e");
      _resetAjandaVerisi();
    }
  }

  void _resetAjandaVerisi() {
    setState(() {
      todos.clear();
      todosChecked.clear();
      notesController.clear();
      postItTexts.clear();
      postItPositions.clear();
      postItVisible.clear();
    });
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
      await yukleAjandaVerisi();
    }
  }

  void _addTodo() {
    final text = todoController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        todos.add(text);
        todosChecked.add(false);
        todoKategorileri.add(secilenKategori!);
        todoController.clear();

        secilenKategori = null;
      });
    }
  }

  void _addPostIt() {
    setState(() {
      postItPositions.add(const Offset(120, 300));
      postItTexts.add("");
      postItVisible.add(true);
    });
  }

  void _toggleDrawing() {
    setState(() {
      isDrawing = !isDrawing;
    });
  }

  void _selectColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  void _undoDrawing() {
    if (lines.isNotEmpty) {
      setState(() {
        lines.removeLast();
      });
    }
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: stickers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
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
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            tooltip: 'Kaydet',
            onPressed: kaydetAjandaVerisi,
          ),
          if (isDrawing)
            IconButton(
              icon: const Icon(
                Icons.undo,
                color: Color.fromARGB(255, 131, 117, 146),
              ),
              onPressed: _undoDrawing,
              tooltip: 'Çizimi geri al',
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFBAC29A)),
              child: Text(
                'MyLog Menüsü',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.highlight, color: Colors.orange),
              title: const Text('Fosforlu Kalem'),
              onTap: _toggleDrawing,
            ),
            ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.purple),
              title: const Text('Kalem Rengini Seç'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          [
                            Colors.yellow,
                            Colors.blue,
                            Colors.pink,
                            Colors.green,
                            Colors.red,
                            Colors.purple,
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
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sticky_note_2_outlined,
                color: Colors.amber,
              ),
              title: const Text('Post-it Ekle'),
              onTap: _addPostIt,
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions, color: Colors.pink),
              title: const Text('Sticker Ekle'),
              onTap: _showStickerPicker,
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text('Ana Sayfa'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profil'),
              onTap: () {
                // Profil sayfasına yönlendirme işlemi buraya eklenecek
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onPanStart:
            isDrawing
                ? (details) {
                  setState(() {
                    currentLine = [details.localPosition];
                  });
                }
                : null,
        onPanUpdate:
            isDrawing
                ? (details) {
                  setState(() {
                    currentLine.add(details.localPosition);
                  });
                }
                : null,
        onPanEnd:
            isDrawing
                ? (details) {
                  setState(() {
                    lines.add(DrawnLine(List.from(currentLine), selectedColor));
                    currentLine.clear();
                  });
                }
                : null,
        child: Stack(
          children: [
            Container(color: const Color(0xFFF2F2F2)), // Arka plan katmanı
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To Do List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    for (int i = 0; i < todos.length; i++)
                      CheckboxListTile(
                        value: todosChecked[i],
                        title: Text(
                          todos[i],
                          style: TextStyle(
                            decoration:
                                todosChecked[i]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text("Kategori: ${todoKategorileri[i]}"),
                        onChanged:
                            (val) =>
                                setState(() => todosChecked[i] = val ?? false),
                        activeColor: Colors.green,
                      ),
                    DropdownButton<String>(
                      value: secilenKategori,
                      hint: const Text('Kategori Seç'),
                      items:
                          kategoriler.map((String kategori) {
                            return DropdownMenuItem<String>(
                              value: kategori,
                              child: Text(kategori),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          secilenKategori = value;
                        });
                      },
                    ),
                    TextField(
                      controller: todoController,
                      decoration: InputDecoration(
                        hintText: 'Yeni görev...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTodo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Notlar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 238, 226, 254),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                          hintText: 'Bugünle ilgili notlar...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stickerlar
            ...stickerPositions.asMap().entries.map((entry) {
              final i = entry.key;
              final offset = entry.value;
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      stickerPositions[i] += details.delta;
                    });
                  },
                  child: Text(
                    stickerTypes[i],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),

            // Post-it'ler
            ...postItPositions.asMap().entries.map((entry) {
              final i = entry.key;
              final offset = entry.value;
              if (!postItVisible[i]) return const SizedBox.shrink();

              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      postItPositions[i] += details.delta;
                    });
                  },
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
                          onChanged: (val) {
                            setState(() {
                              postItTexts[i] = val;
                            });
                          },
                          maxLines: 5,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Not yaz...',
                            hintStyle: TextStyle(color: Colors.black45),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              postItVisible[i] = false;
                            });
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Color.fromARGB(255, 238, 222, 255),
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
