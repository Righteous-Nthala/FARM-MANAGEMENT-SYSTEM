import 'package:farm_wise/components/home_page.dart';
import 'package:flutter/material.dart';
import 'landing_page.dart';

void main() {
  runApp(AgricultureApp());
}

class AgricultureApp extends StatelessWidget {
  //authentication check code
  final bool isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isAuthenticated ? HomePage() : LandingPage(),
    );
  }
}
