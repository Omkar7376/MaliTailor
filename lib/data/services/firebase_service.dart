import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool isFirebaseInitialized = false;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      // Enable Firestore offline persistence
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      isFirebaseInitialized = true;
      debugPrint('Firebase & Firestore successfully initialized with persistence.');
    } catch (e) {
      debugPrint('Firebase not configured with credentials yet ($e). Running in Smart Hybrid/Offline Mode.');
      isFirebaseInitialized = false;
    }
  }
}
