// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9Hgw95BuqpWgfvY0KFv4tLTgFU_kY7oo',
    appId: '1:1007243427375:web:0b167827a96cb545c8d0da',
    messagingSenderId: '1007243427375',
    projectId: 'mylog-19707',
    authDomain: 'mylog-19707.firebaseapp.com',
    storageBucket: 'mylog-19707.firebasestorage.app',
    measurementId: 'G-4MKWSZCEMC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjQ_Wux-WuNXFbayYCYcct4N1pM3Z1WV0',
    appId: '1:1007243427375:android:1402dae4b936650ac8d0da',
    messagingSenderId: '1007243427375',
    projectId: 'mylog-19707',
    storageBucket: 'mylog-19707.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDepjWK5pmAuXZwcwC3wboYm-7x5O4x8lo',
    appId: '1:1007243427375:ios:fdf20a6cb87f8efdc8d0da',
    messagingSenderId: '1007243427375',
    projectId: 'mylog-19707',
    storageBucket: 'mylog-19707.firebasestorage.app',
    iosBundleId: 'com.example.myLog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDepjWK5pmAuXZwcwC3wboYm-7x5O4x8lo',
    appId: '1:1007243427375:ios:fdf20a6cb87f8efdc8d0da',
    messagingSenderId: '1007243427375',
    projectId: 'mylog-19707',
    storageBucket: 'mylog-19707.firebasestorage.app',
    iosBundleId: 'com.example.myLog',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD9Hgw95BuqpWgfvY0KFv4tLTgFU_kY7oo',
    appId: '1:1007243427375:web:529e13960fe6425ac8d0da',
    messagingSenderId: '1007243427375',
    projectId: 'mylog-19707',
    authDomain: 'mylog-19707.firebaseapp.com',
    storageBucket: 'mylog-19707.firebasestorage.app',
    measurementId: 'G-XWCJXTF1YK',
  );
}
