import 'package:farm_wise/components/crop_management/files/crop.dart';
import 'package:farm_wise/components/crop_management/files/fertilizer.dart';
import 'package:farm_wise/components/crop_management/files/pesticides.dart';
import 'package:farm_wise/components/crop_management/files/rrigation.dart';
import 'package:farm_wise/components/crop_management/files/sales.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class CropManagementPage extends StatelessWidget {
  const CropManagementPage({super.key});

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => navigateToPage(context, FertilizerPage()),
                child: Container(
                  padding: const EdgeInsets.all(45),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.white,
                  child: const Text(
                    'Fertilizer',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToPage(context, PesticidesPage()),
                child: Container(
                  padding: const EdgeInsets.all(50),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.white,
                  child: const Text(
                    'Pesticides',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToPage(context, CropPage()),
                child: Container(
                  padding: const EdgeInsets.all(50),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.white,
                  child: const Text(
                    'Crops',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToPage(context, rrigationPage()),
                child: Container(
                  padding: const EdgeInsets.all(50),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.white,
                  child: const Text(
                    'Irrigation',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToPage(context, SalesPage()),
                child: Container(
                  padding: const EdgeInsets.all(50),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.white,
                  child: const Text(
                    'Sales',
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
