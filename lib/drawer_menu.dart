import 'package:flutter/material.dart';
import 'snowfall_widget_web.dart';
import 'habits_web.dart';
import 'calendar_page.dart';

void showMyLogDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "MYLOG Menu",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Material(
            color: const Color(0xFFF9F7F4),
            borderRadius: BorderRadius.circular(20),
            elevation: 10,
            child: Stack(
              children: [
                // ❄️ Kar efekti en arkada
                const Positioned.fill(
                  child: IgnorePointer(child: SnowfallWidgetWeb()),
                ),

                // Drawer içeriği
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Image.asset('web/assets/mylogos.png', height: 90),
                      const Divider(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildBoxButton('web/assets/journal.png', ''),
                          const SizedBox(width: 60),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const CalendarPage(), // hedef sayfa
                                ),
                              );
                            },
                            child: buildBoxButton(
                              'web/assets/planner.png',
                              'Planner',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HabitsWeb(),
                                ),
                              );
                            },
                            child: buildBoxButton(
                              'web/assets/notes.png',
                              'Habits',
                            ),
                          ),
                          const SizedBox(width: 60),
                          buildBoxButton('web/assets/analysis.png', 'Analysis'),
                        ],
                      ),

                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildBoxButton('web/assets/mindmap.png', ''),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text("Kapat"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade100,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      );
    },
  );
}

Widget buildBoxButton(String imagePath, String label) {
  return Container(
    width: 180,
    height: 180,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(3, 3)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover, //  Görsel tüm kutuyu doldurur
      ),
    ),
  );
}
