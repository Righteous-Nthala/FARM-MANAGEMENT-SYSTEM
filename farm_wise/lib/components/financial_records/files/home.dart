import 'package:farm_wise/components/financial_records/analysis.dart';
import 'package:farm_wise/components/financial_records/files/expenses.dart';
import 'package:farm_wise/components/financial_records/files/income.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class FinancialRecordsPage extends StatelessWidget {
  const FinancialRecordsPage({super.key});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Records'),
      ),
      body: Center(
        child:  SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => navigateToPage(context, const ExpensesPage()),
              child: Container(
                padding: const EdgeInsets.all(45),
                margin: const EdgeInsets.symmetric(vertical: 15),
                color: Colors.white,
                child: const Text(
                  'Expenses',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => navigateToPage(context, const IncomePage()),
              child: Container(
                padding: const EdgeInsets.all(50),
                margin: const EdgeInsets.symmetric(vertical: 15),
                color: Colors.white,
                child: const Text(
                  'Income',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => navigateToPage(context, const AnalysisPage()),
              child: Container(
                padding: const EdgeInsets.all(50),
                margin: const EdgeInsets.symmetric(vertical: 15),
                color: Colors.white,
                child: const Text(
                  'Analysis',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }
}
