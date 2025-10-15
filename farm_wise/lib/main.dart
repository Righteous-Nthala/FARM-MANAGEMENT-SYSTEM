import 'package:farm_wise/components/home_page.dart';
import 'package:farm_wise/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final bool supportsFcm = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (supportsFcm) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  runApp(DevicePreview(
    builder: (context) {
      return AgricultureApp();
    },
  ));
}

class AgricultureApp extends StatelessWidget {
  const AgricultureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  Future<void> _initMessagingForUser(User user) async {
    final bool supportsFcm = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!supportsFcm) return;

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('fcmTokens')
          .doc(token)
          .set({'token': token, 'createdAt': FieldValue.serverTimestamp()});
    }

    FirebaseMessaging.onMessage.listen((message) async {
      final data = message.notification;
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .add({
          'title': data.title,
          'body': data.body,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LandingPage();
        }

        _initMessagingForUser(user);
        return const HomePage();
      },
    );
  }
}
