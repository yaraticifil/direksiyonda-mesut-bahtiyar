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
    apiKey: 'AIzaSyBYArx0gnG2cJLGqCo5jNd4b-22GObygQo',
    appId: '1:772761045864:web:081776d56a2b76bf1bc88576806e7090',
    messagingSenderId: '772761045864',
    projectId: 'ortak-yol-driver',
    authDomain: 'ortak-yol-driver.firebaseapp.com',
    storageBucket: 'ortak-yol-driver.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmbCdXX2jKx7QpflPklMjfqwDbToryEFc',
    appId: '1:772761045864:android:e56a8886368d1db3b0a4dd',
    messagingSenderId: '772761045864',
    projectId: 'ortak-yol-driver',
    storageBucket: 'ortak-yol-driver.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAg7U5n94vq0lXBh-d-_iIofq_VuScKfX0',
    appId: '1:772761045864:ios:8f50ea6a52e7bf8ab0a4dd',
    messagingSenderId: '772761045864',
    projectId: 'ortak-yol-driver',
    storageBucket: 'ortak-yol-driver.firebasestorage.app',
    iosBundleId: 'com.ortakyol.driver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAg7U5n94vq0lXBh-d-_iIofq_VuScKfX0',
    appId: '1:772761045864:ios:8f50ea6a52e7bf8ab0a4dd',
    messagingSenderId: '772761045864',
    projectId: 'ortak-yol-driver',
    storageBucket: 'ortak-yol-driver.firebasestorage.app',
    iosBundleId: 'com.ortakyol.driver',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAg7U5n94vq0lXBh-d-_iIofq_VuScKfX0',
    appId: '1:772761045864:web:081776d56a2b76bf1bc88576806e7090',
    messagingSenderId: '772761045864',
    projectId: 'ortak-yol-driver',
    authDomain: 'ortak-yol-driver.firebaseapp.com',
    storageBucket: 'ortak-yol-driver.firebasestorage.app',
  );
}
