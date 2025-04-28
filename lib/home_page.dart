import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'snowfall_widget.dart';
import 'snowfall_page.dart';
import 'calendar_page.dart';
import 'journal_page.dart';
import 'mind_map.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          'MYLOG',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                'MyLog Menüsü',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Planner'),
              onTap: () => Navigator.pushNamed(context, '/planner'),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Journal'),
              onTap: () => Navigator.pushNamed(context, '/journal'),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: () => Navigator.pushNamed(context, '/notes'),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Mind Map'),
              onTap: () => Navigator.pushNamed(context, '/mindmap'),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Analysis'),
              onTap: () => Navigator.pushNamed(context, '/analysis'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const SnowfallBackground(),
          const SnowfallWidget(),
          Column(
            children: [
              const SizedBox(height: 8),
              Center(child: Image.asset('assets/mylogos.png', height: 120)),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureButton(
                        context,
                        'assets/journal.png',
                        '/journal',
                      ),
                      _buildFeatureButton(
                        context,
                        'assets/planner.png',
                        '/planner',
                      ),
                      _buildFeatureButton(
                        context,
                        'assets/notes.png',
                        '/notes',
                      ),
                      _buildFeatureButton(
                        context,
                        'assets/analysis.png',
                        '/analysis',
                      ),
                      _buildFeatureButton(
                        context,
                        'assets/mindmap.png',
                        '/mindmap',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String assetPath,
    String routeName,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(routeName),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
