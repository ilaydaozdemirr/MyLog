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
    'Job',
    'School',
    'Sport',
    'Personal',
    'Health',
    'Shopping',
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
        'checked': todosChecked,
        'kategoriler': todoKategorileri,
        'notlar': notesController.text,
        'postitler': postItTexts,
        'postitKonumlari':
            postItPositions.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
        'stickerler': stickerTypes,
        'stickerKonumlari':
            stickerPositions.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      });
      // ✅ Kayıt başarılıysa mini dialog aç:
      showDialog(
        context: context,
        barrierDismissible: false, // Tıklayınca hemen kapanmasın
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true); // 2 saniye sonra kapat
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 20),
                Text(
                  "Agenda saved!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      );

      debugPrint("✅ Agenda saved successfully!");
    } catch (e) {
      debugPrint("🔥 Error while saving the agenda: $e");
    }
  }

  Future<void> yukleAjandaVerisi() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = FirebaseFirestore.instance
          .collection('ajanda')
          .doc(uid)
          .collection('gunler')
          .doc(selectedDate.toIso8601String());

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          setState(() {
            todos
              ..clear()
              ..addAll(List<String>.from(data['todos'] ?? []));

            todosChecked
              ..clear()
              ..addAll(
                List<bool>.from(
                  data['checked'] ?? List<bool>.filled(todos.length, false),
                ),
              );

            todoKategorileri
              ..clear()
              ..addAll(
                List<String>.from(
                  data['kategoriler'] ??
                      List<String>.filled(todos.length, 'Genel'),
                ),
              );

            notesController.text = data['notlar'] ?? '';

            postItTexts
              ..clear()
              ..addAll(List<String>.from(data['postitler'] ?? []));

            postItPositions
              ..clear()
              ..addAll(
                List<Map<String, dynamic>>.from(
                  data['postitKonumlari'] ?? [],
                ).map(
                  (e) => Offset(
                    (e['x'] as num).toDouble(),
                    (e['y'] as num).toDouble(),
                  ),
                ),
              );

            postItVisible
              ..clear()
              ..addAll(List<bool>.filled(postItTexts.length, true));
            // 📌 YENİ EKLENDİ: Sticker veri yükleme
            stickerTypes
              ..clear()
              ..addAll(List<String>.from(data['stickerler'] ?? []));

            stickerPositions
              ..clear()
              ..addAll(
                List<Map<String, dynamic>>.from(
                  data['stickerKonumlari'] ?? [],
                ).map(
                  (e) => Offset(
                    (e['x'] as num).toDouble(),
                    (e['y'] as num).toDouble(),
                  ),
                ),
              );
          });

          debugPrint("✅ Ajanda verisi başarıyla yüklendi!");
        }
      } else {
        _resetAjandaVerisi();
        debugPrint("⚪ Ajanda boş, sıfırlandı.");
      }
    } catch (e) {
      debugPrint("🔥 Ajanda yüklerken hata: $e");
      _resetAjandaVerisi();
    }
  }

  void _resetAjandaVerisi() {
    setState(() {
      todos.clear();
      todosChecked.clear();
      todoKategorileri.clear();
      notesController.clear();
      postItTexts.clear();
      postItPositions.clear();
      postItVisible.clear();

      // 📌 YENİ EKLENDİ: Stickerları da sıfırla
      stickerTypes.clear();
      stickerPositions.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => yukleAjandaVerisi());
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

  void _editTodoDialog(int index) {
    final TextEditingController editController = TextEditingController(
      text: todos[index],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Add a new task'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todos[index] = editController.text;
                });
                kaydetAjandaVerisi();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
      todosChecked.removeAt(index);
      if (index < todoKategorileri.length) {
        todoKategorileri.removeAt(index);
      }
    });
    kaydetAjandaVerisi();
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
              crossAxisCount: 6,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(2, 4), // gölge yönü
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
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
            tooltip: 'Save',
            onPressed: kaydetAjandaVerisi,
          ),
          if (isDrawing)
            IconButton(
              icon: const Icon(
                Icons.undo,
                color: Color.fromARGB(255, 131, 117, 146),
              ),
              onPressed: _undoDrawing,
              tooltip: 'Undo drawing',
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(245, 227, 225, 221),
              ),
              child: Text(
                ' MYLOG Menu',
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
              title: const Text('Add Post-it'),
              onTap: _addPostIt,
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions, color: Colors.pink),
              title: const Text('Add Sticker'),
              onTap: _showStickerPicker,
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CheckboxListTile(
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
                              subtitle: Text(
                                "Category: ${i < todoKategorileri.length ? todoKategorileri[i] : 'General'}",
                              ),
                              onChanged: (val) {
                                setState(() {
                                  todosChecked[i] = val ?? false;
                                });
                                kaydetAjandaVerisi();
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editTodoDialog(i); // düzenleme fonksiyonu
                              } else if (value == 'delete') {
                                _deleteTodo(i); // silme fonksiyonu
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    DropdownButton<String>(
                      value: secilenKategori,
                      hint: const Text('Select Category'),
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
                        hintText: 'New task...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTodo,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Notes',
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
                          hintText: 'Notes about today...',
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
                  onLongPress: () {
                    // 🛑 Uzun basınca silme menüsü açılıyor
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete sticker'),
                          content: const Text(
                            'Are you sure you want to delete this sticker?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  stickerPositions.removeAt(i);
                                  stickerTypes.removeAt(i);
                                });
                                Navigator.pop(context);
                                kaydetAjandaVerisi();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
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
                            hintText: 'Write a note...',
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
