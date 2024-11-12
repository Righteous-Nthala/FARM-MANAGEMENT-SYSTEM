import 'package:flutter/material.dart';

class CropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Management')),
      body: const Center(
        child: Text(
          'Crop Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
