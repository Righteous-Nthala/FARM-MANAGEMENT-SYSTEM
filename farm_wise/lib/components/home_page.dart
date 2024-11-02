import 'package:flutter/material.dart';
import 'utils/base_page.dart';
import 'crop_management/files/home.dart';
import 'livestock_management/files/home.dart';
import 'farm_inputs/files/home.dart';
import 'financial_records/files/home.dart';
import 'labor_records/files/home.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth * 0.05; // Dynamic spacing based on screen size

    return BasePage(
      currentIndex: 0, // Set index for Home tab
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/image6.jpeg', // Replace with your logo image asset
              fit: BoxFit.contain,
            ),
          ),
          title: Container(
            width: double.infinity,
            height: 40,
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                // Add functionality for profile icon if needed
              },
            ),
          ],
          backgroundColor: Colors.green,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30), // Top margin for the text
              const Text(
                'FROM FIELD TO TABLE MADE EASY',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Image.asset(
                'images/image2.jpeg', // Replace with your farm image asset
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 30),

              // Wrap the main navigation buttons in a Wrap widget
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: [
                  _buildNavButton(context, 'Crop Management', CropManagementPage()),
                  _buildNavButton(context, 'Livestock Management', LivestockManagementPage()),
                  _buildNavButton(context, 'Farm Inputs', FarmInputsPage()),
                  _buildNavButton(context, 'Labor Records', LaborRecordsPage()),
                ],
              ),
              SizedBox(height: 20),

              // Separate button for Financial Records
              _buildFinancialRecordsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, Widget page) {
    return SizedBox(
      width: 180,
      height: 80,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFinancialRecordsButton(BuildContext context) {
    return SizedBox(
      width: 380,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FinancialRecordsPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Different color for Financial Records button
          side: BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text(
          'Financial Records',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
