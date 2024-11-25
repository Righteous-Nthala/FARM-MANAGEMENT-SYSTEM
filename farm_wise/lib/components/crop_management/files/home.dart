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

  Widget buildNavigationButton(BuildContext context, String title, Widget page) {
    return SizedBox(
      width: 300,  // Set fixed width for consistency
      height: 120,  // Set fixed height for consistency
      child: ElevatedButton(
        onPressed: () => navigateToPage(context, page),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.green), // Border color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Adjust padding as needed
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Management'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildNavigationButton(context, 'Crops', CropRecordsPage()),
              const SizedBox(height: 15),
              buildNavigationButton(context, 'Pesticides', PesticidesRecordsPage()),
              const SizedBox(height: 15),
              buildNavigationButton(context, 'Fertilizer', FertilizerRecordsPage()),
              const SizedBox(height: 15),
              buildNavigationButton(context, 'Irrigation', IrrigationRecordsPage()),
              const SizedBox(height: 15),
              buildNavigationButton(context, 'Sales', SalesRecordsPage()),
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
