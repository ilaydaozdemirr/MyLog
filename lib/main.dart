import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_page.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'journal_page.dart';
import 'mind_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notes_habit_page.dart';
import 'analysis_page.dart';
import 'package:flutter/foundation.dart'; // kIsWeb için

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyLog',
      locale: const Locale('tr', 'TR'),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home:
          const AuthPage(), // ← işte burası uygulama ilk açıldığında görülecek ekran
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
        '/planner': (context) => const CalendarPage(),
        '/journal': (context) => const JournalPage(),
        '/mindmap': (context) => const MindMapPage(),
        '/notes': (context) => const NotesHabitPage(),
        '/analysis': (context) => const AnalysisPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const AuthPage();
      },
    );
  }
}
