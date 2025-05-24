import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart'; // Tarih formatı için
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Habit {
  String title;
  DateTime startDate;
  int duration;
  List<bool> completedDays;
  int order;

  Habit({
    required this.title,
    required this.startDate,
    required this.duration,
    required this.completedDays,
    required this.order,
  });

  bool get isCompleted => completedDays.every((day) => day);
}

class HabitsWeb extends StatefulWidget {
  const HabitsWeb({Key? key}) : super(key: key);

  @override
  State<HabitsWeb> createState() => _HabitsWebState();
}

class _HabitsWebState extends State<HabitsWeb> {
  final TextEditingController _habitController = TextEditingController();
  final List<Habit> _habits = [];
  int _selectedDays = 7;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('habits')
            .doc(uid)
            .collection('users')
            .orderBy('order') // sıraya göre çekiyoruz
            .get();

    final List<Habit> loadedHabits =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return Habit(
            title: data['title'] ?? '',
            startDate: DateTime.parse(data['startDate']),
            duration: data['duration'] ?? 7,
            completedDays: List<bool>.from(data['completedDays'] ?? []),
            order: data['order'] ?? 0,
          );
        }).toList();

    setState(() {
      _habits.clear();
      _habits.addAll(loadedHabits);
    });
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  Future<void> _updateHabitOrder(Habit habit, int newOrder) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('habits')
            .doc(uid)
            .collection('users')
            .where('title', isEqualTo: habit.title)
            .where('startDate', isEqualTo: habit.startDate.toIso8601String())
            .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({'order': newOrder});
    }
  }

  Future<void> _addHabit() async {
    if (_habitController.text.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      Habit newHabit = Habit(
        title: _habitController.text,
        startDate: DateTime.now(),
        duration: _selectedDays,
        completedDays: List.generate(_selectedDays, (index) => false),
        order: _habits.length,
      );

      setState(() {
        _habits.add(newHabit);
        _habitController.clear();
      });

      await FirebaseFirestore.instance
          .collection('habits')
          .doc(uid)
          .collection('users')
          .add({
            'title': newHabit.title,
            'startDate': newHabit.startDate.toIso8601String(),
            'duration': newHabit.duration,
            'completedDays': newHabit.completedDays,
            'order': newHabit.order,
          });
    }
  }

  void _moveUp(int index) async {
    if (index > 0) {
      setState(() {
        final temp = _habits[index];
        _habits[index] = _habits[index - 1];
        _habits[index - 1] = temp;
      });
      await _updateHabitOrder(_habits[index], index);
      await _updateHabitOrder(_habits[index - 1], index - 1);
    }
  }

  void _moveDown(int index) async {
    if (index < _habits.length - 1) {
      setState(() {
        final temp = _habits[index];
        _habits[index] = _habits[index + 1];
        _habits[index + 1] = temp;
      });
      await _updateHabitOrder(_habits[index], index);
      await _updateHabitOrder(_habits[index + 1], index + 1);
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this habit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('habits')
              .doc(uid)
              .collection('users')
              .where('title', isEqualTo: habit.title)
              .where('startDate', isEqualTo: habit.startDate.toIso8601String())
              .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _habits.remove(habit);
      });
    }
  }

  void _toggleDay(Habit habit, int dayIndex) async {
    final today = DateTime.now();
    final targetDate = habit.startDate.add(Duration(days: dayIndex));

    if (today.year == targetDate.year &&
        today.month == targetDate.month &&
        today.day == targetDate.day) {
      setState(() {
        habit.completedDays[dayIndex] = true;
      });

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('habits')
              .doc(uid)
              .collection('users')
              .where('title', isEqualTo: habit.title)
              .where('startDate', isEqualTo: habit.startDate.toIso8601String())
              .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'completedDays': habit.completedDays,
        });
      }

      if (habit.completedDays.every((completed) => completed)) {
        _showCompletionDialog(habit.title);
      }
    }
  }

  void _showCompletionDialog(String habitTitle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Congratulations! 🎉'),
            content: Text(
              'You have successfully completed your habit: $habitTitle!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  double _calculateGeneralSuccessRate() {
    int totalDays = 0;
    int completedDays = 0;

    for (final habit in _habits) {
      totalDays += habit.duration;
      completedDays +=
          habit.completedDays.where((completed) => completed).length;
    }

    if (totalDays == 0) return 0;
    return completedDays / totalDays;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits and Reminders'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 242, 242),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Today: $today', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 70.0,
              lineWidth: 10.0,
              percent: _calculateGeneralSuccessRate(),
              center: Text(
                '${(_calculateGeneralSuccessRate() * 100).toStringAsFixed(1)}%',
              ),
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade300,
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(
                labelText: 'Add new habit/reminder',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Select Duration:'),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedDays,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDays = newValue;
                      });
                    }
                  },
                  items:
                      [7, 14, 21, 30, 60, 90].map((days) {
                        return DropdownMenuItem<int>(
                          value: days,
                          child: Text('$days days'),
                        );
                      }).toList(),
                ),
                const Spacer(),
                ElevatedButton(onPressed: _addHabit, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Show Completed'),
                Switch(
                  value: _showCompleted,
                  onChanged: (value) {
                    setState(() {
                      _showCompleted = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _habits.length,
                itemBuilder: (context, index) {
                  final habit = _habits[index];
                  if (!_showCompleted && habit.isCompleted)
                    return const SizedBox();

                  final habitSuccess =
                      habit.completedDays.where((c) => c).length /
                      habit.duration;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  habit.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'move_up') {
                                    if (index > 0) {
                                      setState(() {
                                        final temp = _habits[index];
                                        _habits[index] = _habits[index - 1];
                                        _habits[index - 1] = temp;
                                      });
                                      await _updateHabitOrder(
                                        _habits[index],
                                        index,
                                      );
                                      await _updateHabitOrder(
                                        _habits[index - 1],
                                        index - 1,
                                      );
                                    }
                                  } else if (value == 'move_down') {
                                    if (index < _habits.length - 1) {
                                      setState(() {
                                        final temp = _habits[index];
                                        _habits[index] = _habits[index + 1];
                                        _habits[index + 1] = temp;
                                      });
                                      await _updateHabitOrder(
                                        _habits[index],
                                        index,
                                      );
                                      await _updateHabitOrder(
                                        _habits[index + 1],
                                        index + 1,
                                      );
                                    }
                                  } else if (value == 'delete') {
                                    _deleteHabit(habit);
                                  }
                                },
                                itemBuilder:
                                    (BuildContext context) => [
                                      const PopupMenuItem(
                                        value: 'move_up',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Move Up'),
                                            Icon(Icons.arrow_upward),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'move_down',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Move Down'),
                                            Icon(Icons.arrow_downward),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Delete'),
                                            Icon(Icons.delete),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 8.0,
                            percent: habitSuccess,
                            center: Text(
                              '${(habitSuccess * 100).toStringAsFixed(0)}%',
                            ),
                            progressColor: Colors.blueAccent,
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: List.generate(habit.duration, (dayIndex) {
                              final targetDate = habit.startDate.add(
                                Duration(days: dayIndex),
                              );
                              final now = DateTime.now();

                              bool isToday =
                                  now.year == targetDate.year &&
                                  now.month == targetDate.month &&
                                  now.day == targetDate.day;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('d MMM').format(targetDate),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Checkbox(
                                    value: habit.completedDays[dayIndex],
                                    onChanged:
                                        isToday
                                            ? (_) => _toggleDay(habit, dayIndex)
                                            : null,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
