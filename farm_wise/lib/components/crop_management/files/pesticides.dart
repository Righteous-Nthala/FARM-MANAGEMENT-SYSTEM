import 'package:flutter/material.dart';

class PesticidesPage extends StatelessWidget {
  const PesticidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesticides Management')),
      body: const Center(
        child: Text(
          'Pesticides Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
