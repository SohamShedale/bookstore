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
    apiKey: 'AIzaSyAm2CWLnNLR0c7Kqs6YX2esfnO9ozJlEEo',
    appId: '1:1096161594049:web:0b0f2d178e4b4da037e240',
    messagingSenderId: '1096161594049',
    projectId: 'bookstore-2559f',
    authDomain: 'bookstore-2559f.firebaseapp.com',
    storageBucket: 'bookstore-2559f.firebasestorage.app',
    measurementId: 'G-YD64D0TQ3K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXMzVoik-HZaoORVPVFKfnmNNBr72MUvk',
    appId: '1:1096161594049:android:4aae3c2055a4bb4237e240',
    messagingSenderId: '1096161594049',
    projectId: 'bookstore-2559f',
    storageBucket: 'bookstore-2559f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRs3aKb30AePUkbIstMtXE3eo7zWjRqPQ',
    appId: '1:1096161594049:ios:79fe35ed2e504ecb37e240',
    messagingSenderId: '1096161594049',
    projectId: 'bookstore-2559f',
    storageBucket: 'bookstore-2559f.firebasestorage.app',
    androidClientId: '1096161594049-d6o6a192954s07us48v2hbhvrfer6d7e.apps.googleusercontent.com',
    iosClientId: '1096161594049-nb2n0n96stkr413lgsv53gm8uv95tu0h.apps.googleusercontent.com',
    iosBundleId: 'com.example.bookstore',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBRs3aKb30AePUkbIstMtXE3eo7zWjRqPQ',
    appId: '1:1096161594049:ios:79fe35ed2e504ecb37e240',
    messagingSenderId: '1096161594049',
    projectId: 'bookstore-2559f',
    storageBucket: 'bookstore-2559f.firebasestorage.app',
    androidClientId: '1096161594049-d6o6a192954s07us48v2hbhvrfer6d7e.apps.googleusercontent.com',
    iosClientId: '1096161594049-nb2n0n96stkr413lgsv53gm8uv95tu0h.apps.googleusercontent.com',
    iosBundleId: 'com.example.bookstore',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAm2CWLnNLR0c7Kqs6YX2esfnO9ozJlEEo',
    appId: '1:1096161594049:web:1edc68f5d965c1b337e240',
    messagingSenderId: '1096161594049',
    projectId: 'bookstore-2559f',
    authDomain: 'bookstore-2559f.firebaseapp.com',
    storageBucket: 'bookstore-2559f.firebasestorage.app',
    measurementId: 'G-KB7SMFX10E',
  );

}