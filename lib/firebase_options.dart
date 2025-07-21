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
    apiKey: 'AIzaSyBQqTrv6pOE14veUrp50CGLWCXQMCfoDj8',
    appId: '1:125884063418:web:c0f01faa6f075693b2ac83',
    messagingSenderId: '125884063418',
    projectId: 'bengkelapp-9ea95',
    authDomain: 'bengkelapp-9ea95.firebaseapp.com',
    storageBucket: 'bengkelapp-9ea95.firebasestorage.app',
    measurementId: 'G-F5BLKNP04W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEoxYpfGjIh6IPZ0je10s3Ga9K0zAeWH0',
    appId: '1:125884063418:android:17342d894f32a0e8b2ac83',
    messagingSenderId: '125884063418',
    projectId: 'bengkelapp-9ea95',
    storageBucket: 'bengkelapp-9ea95.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZnxlp8-_FH7gUHN1d9uCr4MDMvZmHdOg',
    appId: '1:125884063418:ios:0d283bf8201011bab2ac83',
    messagingSenderId: '125884063418',
    projectId: 'bengkelapp-9ea95',
    storageBucket: 'bengkelapp-9ea95.firebasestorage.app',
    iosBundleId: 'com.example.mybengkel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'YOUR-MACOS-BUNDLE-ID',
  );
}