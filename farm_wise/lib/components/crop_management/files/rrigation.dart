import 'package:flutter/material.dart';

class rrigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation Management')),
      body: const Center(
        child: Text(
          'Irrigation Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
