import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MonthlyGoalsPage extends StatefulWidget {
  final VoidCallback onNext;
  const MonthlyGoalsPage({super.key, required this.onNext});

  @override
  State<MonthlyGoalsPage> createState() => _MonthlyGoalsPageState();
}

class _MonthlyGoalsPageState extends State<MonthlyGoalsPage> {
  final List<String> tasks = [];
  final List<bool> taskChecks = [];
  final TextEditingController taskController = TextEditingController();

  final List<String> movies = [];
  final List<bool> movieChecks = [];
  final TextEditingController movieController = TextEditingController();

  final List<String> travels = [];
  final List<bool> travelChecks = [];
  final TextEditingController travelController = TextEditingController();

  final List<String> books = [];
  final List<bool> bookChecks = [];
  final TextEditingController bookController = TextEditingController();

  Future<void> loadMonthlyGoalsFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final now = DateTime.now();
      final monthKey = DateFormat('yyyy-MM').format(now);

      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('monthly_goals')
              .doc(uid)
              .collection('users')
              .doc(monthKey)
              .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final goals = data?['goals'];

        debugPrint("GOALS FROM FIRESTORE:");
        debugPrint(goals.toString());

        setState(() {
          tasks
            ..clear()
            ..addAll(List<String>.from(goals['general_tasks']['items'] ?? []));
          taskChecks
            ..clear()
            ..addAll(List<bool>.from(goals['general_tasks']['checks'] ?? []));

          movies
            ..clear()
            ..addAll(List<String>.from(goals['movies']['items'] ?? []));
          movieChecks
            ..clear()
            ..addAll(List<bool>.from(goals['movies']['checks'] ?? []));

          books
            ..clear()
            ..addAll(List<String>.from(goals['books']['items'] ?? []));
          bookChecks
            ..clear()
            ..addAll(List<bool>.from(goals['books']['checks'] ?? []));

          travels
            ..clear()
            ..addAll(List<String>.from(goals['travels']['items'] ?? []));
          travelChecks
            ..clear()
            ..addAll(List<bool>.from(goals['travels']['checks'] ?? []));
        });
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
    }
  }

  void _showEditDialog(List<String> items, int index) {
    final TextEditingController editController = TextEditingController(
      text: items[index],
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Task"),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: "Enter new text..."),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    items[index] = editController.text.trim();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadMonthlyGoalsFromFirestore(); // 🔹 Sayfa yüklenince veriyi çek
  }

  void _confirmDelete(List<String> items, List<bool> checks, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Task"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    items.removeAt(index);
                    checks.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final today = DateTime.now();
        if (today.day == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MonthlyGoalsPage(onNext: widget.onNext),
            ),
          );
          return false;
        }
        return true;
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Monthly Goals",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildGeneralTasksSection(),
                const SizedBox(height: 30),
                _buildSection(
                  "🎬 Movies to Watch",
                  'assets/movies.jpg',
                  movieController,
                  movies,
                  movieChecks,
                ),
                const SizedBox(height: 30),
                _buildSection(
                  "✈️ Places to Visit",
                  'assets/travel.jpg',
                  travelController,
                  travels,
                  travelChecks,
                ),
                const SizedBox(height: 30),
                _buildSection(
                  "📚 Books to Read",
                  'assets/books.jpg',
                  bookController,
                  books,
                  bookChecks,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Monthly Goals",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.deepPurple),
              onPressed: saveMonthlyGoalsToFirestore,
              tooltip: 'Save Goals',
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: widget.onNext,
          label: const Text("Go to Calendar"),
          icon: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String imagePath,
    TextEditingController controller,
    List<String> items,
    List<bool> checks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Add a new item...",
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    items.add(text);
                    checks.add(false);
                    controller.clear();
                  });
                }
              },
            ),
          ],
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;

          return ListTile(
            leading: Checkbox(
              value: checks[index],
              onChanged: (val) {
                setState(() {
                  checks[index] = val ?? false;
                });
              },
            ),
            title: Text(text),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(items, index);
                } else if (value == 'delete') {
                  _confirmDelete(items, checks, index); // 🔹 Güncellendi
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGeneralTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🧠 General Monthly Tasks",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: taskController,
                decoration: InputDecoration(
                  hintText: "Add a new goal...",
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: () {
                final text = taskController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    tasks.add(text);
                    taskChecks.add(false);
                    taskController.clear();
                  });
                }
              },
            ),
          ],
        ),
        ...tasks.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;

          return ListTile(
            leading: Checkbox(
              value: taskChecks[index],
              onChanged: (val) {
                setState(() {
                  taskChecks[index] = val ?? false;
                });
              },
            ),
            title: Text(text),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(tasks, index);
                } else if (value == 'delete') {
                  _confirmDelete(tasks, taskChecks, index);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> saveMonthlyGoalsToFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final now = DateTime.now();
      final monthKey = DateFormat('yyyy-MM').format(now);

      final Map<String, dynamic> hedefler = {
        'general_tasks': {'items': tasks, 'checks': taskChecks},
        'movies': {'items': movies, 'checks': movieChecks},
        'books': {'items': books, 'checks': bookChecks},
        'travels': {'items': travels, 'checks': travelChecks},
      };

      await FirebaseFirestore.instance
          .collection('monthly_goals')
          .doc(uid)
          .collection('users')
          .doc(monthKey)
          .set({'goals': hedefler, 'timestamp': FieldValue.serverTimestamp()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals successfully saved.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save error: $e')));
    }
  }

  @override
  void dispose() {
    taskController.dispose();
    movieController.dispose();
    travelController.dispose();
    bookController.dispose();
    super.dispose();
  }
}
