import 'package:flutter/material.dart';

class FertilizerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fertilizer Management')),
      body: const Center(
        child: Text(
          'Fertilizer Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
