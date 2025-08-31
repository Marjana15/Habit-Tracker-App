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
    apiKey: 'AIzaSyBFNCwjsbHKS8XuO8QMXxcqKmGXqezQqpI',
    appId: '1:734686170315:web:dce66540bf56926f4edf4e',
    messagingSenderId: '734686170315',
    projectId: 'habittrackerapp-ad2e6',
    authDomain: 'habittrackerapp-ad2e6.firebaseapp.com',
    storageBucket: 'habittrackerapp-ad2e6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAtL05ZKQ8MrKjCXehjDTRDC_DEYH2v-Y8',
    appId: '1:734686170315:android:3be8a7ecc82e76dd4edf4e',
    messagingSenderId: '734686170315',
    projectId: 'habittrackerapp-ad2e6',
    storageBucket: 'habittrackerapp-ad2e6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATU_9HQJS8kXBVILGz0q1u--NQATaoBI0',
    appId: '1:734686170315:ios:83ed46c91f8dd34e4edf4e',
    messagingSenderId: '734686170315',
    projectId: 'habittrackerapp-ad2e6',
    storageBucket: 'habittrackerapp-ad2e6.firebasestorage.app',
    iosBundleId: 'com.example.habittrackerapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyATU_9HQJS8kXBVILGz0q1u--NQATaoBI0',
    appId: '1:734686170315:ios:83ed46c91f8dd34e4edf4e',
    messagingSenderId: '734686170315',
    projectId: 'habittrackerapp-ad2e6',
    storageBucket: 'habittrackerapp-ad2e6.firebasestorage.app',
    iosBundleId: 'com.example.habittrackerapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBFNCwjsbHKS8XuO8QMXxcqKmGXqezQqpI',
    appId: '1:734686170315:web:2d5486fa9fe563044edf4e',
    messagingSenderId: '734686170315',
    projectId: 'habittrackerapp-ad2e6',
    authDomain: 'habittrackerapp-ad2e6.firebaseapp.com',
    storageBucket: 'habittrackerapp-ad2e6.firebasestorage.app',
  );
}
