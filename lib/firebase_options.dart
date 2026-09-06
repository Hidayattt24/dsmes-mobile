import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform yet.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhSrsXRNBicBK46XsoRA6bIPHhhUfgBZI',
    appId: '1:35833625304:android:ebb29564c780d8829cf5ad',
    messagingSenderId: '35833625304',
    projectId: 'dsmes-notification',
    storageBucket: 'dsmes-notification.firebasestorage.app',
  );
}
