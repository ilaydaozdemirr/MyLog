import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page_web.dart'; // Web ana sayfan
import 'auth_page_web.dart';
import 'register_page_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "REMOVED_SECRET",
      authDomain: "mylog-a11ee.firebaseapp.com",
      projectId: "mylog-a11ee",
      storageBucket: "mylog-a11ee.firebasestorage.app",
      messagingSenderId: "520781371971",
      appId: "1:520781371971:web:d4d9701464392e3d0ad2f6",
      measurementId: "G-8SLGJW0EMK",
    ),
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePageWeb(),
        '/login': (context) => const AuthPageWeb(),
        '/register': (context) => const RegisterPageWeb(),
      },
      builder: (context, child) {
        return Overlay(
          initialEntries: [OverlayEntry(builder: (context) => child!)],
        );
      },
    ),
  );
}
