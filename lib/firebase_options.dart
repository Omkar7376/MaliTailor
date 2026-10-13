import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Generated from Firebase project credentials:
/// Project ID: stitchup05
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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBtX4zo3LmeQ8qgmPj7oqrOOi1fiGCRrSE',
    appId: '1:42293825852:web:4f490ca7a05ddb20f8ce39',
    messagingSenderId: '42293825852',
    projectId: 'stitchup05',
    authDomain: 'stitchup05.firebaseapp.com',
    storageBucket: 'stitchup05.firebasestorage.app',
    measurementId: 'G-JYH6X926VM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtX4zo3LmeQ8qgmPj7oqrOOi1fiGCRrSE',
    appId: '1:42293825852:web:4f490ca7a05ddb20f8ce39',
    messagingSenderId: '42293825852',
    projectId: 'stitchup05',
    authDomain: 'stitchup05.firebaseapp.com',
    storageBucket: 'stitchup05.firebasestorage.app',
    measurementId: 'G-JYH6X926VM',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtX4zo3LmeQ8qgmPj7oqrOOi1fiGCRrSE',
    appId: '1:42293825852:web:4f490ca7a05ddb20f8ce39',
    messagingSenderId: '42293825852',
    projectId: 'stitchup05',
    authDomain: 'stitchup05.firebaseapp.com',
    storageBucket: 'stitchup05.firebasestorage.app',
    measurementId: 'G-JYH6X926VM',
  );
}
