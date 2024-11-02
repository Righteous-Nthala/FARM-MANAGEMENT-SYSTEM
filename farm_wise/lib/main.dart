import 'package:farm_wise/components/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AgricultureApp());
}

class AgricultureApp extends StatelessWidget {
  const AgricultureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agriculture App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}
