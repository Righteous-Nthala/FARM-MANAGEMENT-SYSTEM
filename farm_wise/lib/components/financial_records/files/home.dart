import 'package:flutter/material.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class FinancialRecordsPage extends StatelessWidget {
  const FinancialRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Records')),
      body: const Center(child: Text('Financial Records Page')),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }
}