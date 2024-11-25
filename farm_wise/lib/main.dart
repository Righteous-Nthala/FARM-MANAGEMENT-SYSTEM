import 'package:farm_wise/components/home_page.dart';
import 'package:farm_wise/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'landing_page.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(AgricultureApp());
}

class AgricultureApp extends StatelessWidget {
  //authentication check code
  final bool isAuthenticated = false;

  const AgricultureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isAuthenticated ? HomePage() : LandingPage(),
    );
  }
}
