// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: "AIzaSyBQgyL0Hb_aGBKqXcrX4VFieV1t5wy-fHg",
    authDomain: "shnatter-dev.firebaseapp.com",
    projectId: "shnatter-dev",
    storageBucket: "shnatter-dev.appspot.com",
    messagingSenderId: "414573634624",
    appId: "1:414573634624:web:b5fdcde8e6d690b12b6ba5",
    measurementId: "G-Q9E4VFRFCZ",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQgyL0Hb_aGBKqXcrX4VFieV1t5wy-fHg',
    appId: '1:414573634624:android:8d5d0fc6f5db25902b6ba5',
    messagingSenderId: '414573634624',
    projectId: 'shnatter-dev',
    databaseURL: 'https://shnatter-dev-default-rtdb.firebaseio.com',
    storageBucket: 'shnatter-dev.appspot.com',
    androidClientId:
        '414573634624-idmquvtvjovu9uta10i65f171i1h6ihe.apps.googleusercontent.com',
    iosClientId:
        '414573634624-m58j5kj5qa9uppli2ovt9p0fmme04pep.apps.googleusercontent.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVFkvmDRFZuuKlHTEPRS5h2y5S8kaQE6A',
    appId: '1:414573634624:ios:a7dc5ce7b040ddb62b6ba5',
    messagingSenderId: '414573634624',
    projectId: 'shnatter-dev',
    databaseURL: 'https://shnatter-dev-default-rtdb.firebaseio.com',
    storageBucket: 'shnatter-dev.appspot.com',
    androidClientId:
        '414573634624-idmquvtvjovu9uta10i65f171i1h6ihe.apps.googleusercontent.com',
    iosClientId:
        '414573634624-m58j5kj5qa9uppli2ovt9p0fmme04pep.apps.googleusercontent.com',
    iosBundleId: 'com.shnatter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVFkvmDRFZuuKlHTEPRS5h2y5S8kaQE6A',
    appId: '1:414573634624:ios:a7dc5ce7b040ddb62b6ba5',
    messagingSenderId: '414573634624',
    projectId: 'shnatter-dev',
    databaseURL: 'https://shnatter-dev-default-rtdb.firebaseio.com',
    storageBucket: 'shnatter-dev.appspot.com',
    androidClientId:
        '414573634624-idmquvtvjovu9uta10i65f171i1h6ihe.apps.googleusercontent.com',
    iosClientId:
        '414573634624-m58j5kj5qa9uppli2ovt9p0fmme04pep.apps.googleusercontent.com',
    iosBundleId: 'com.shnatter',
  );
}
