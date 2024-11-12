import 'package:flutter/material.dart';

class SalesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Management')),
      body: const Center(
        child: Text(
          'Sales Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
