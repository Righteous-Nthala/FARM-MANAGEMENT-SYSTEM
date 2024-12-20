import 'package:flutter/material.dart';
import 'dart:async';
import 'utils/base_page.dart';
import 'crop_management/files/home.dart';
import 'livestock_management/files/home.dart';
import 'farm_inputs/files/home.dart';
import 'financial_records/files/home.dart';
import 'labor_records/files/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _searchableItems = [
    {'title': 'Crop Management', 'page': CropManagementPage()},
    {'title': 'Livestock Management', 'page': LivestockManagementPage()},
    {'title': 'Farm Inputs', 'page': FarmInputsPage()},
    {'title': 'Labor Records', 'page': Home()},
  ];

  final List<String> _imagePaths = [
    'images/image1.jpeg',
    'images/image2.jpeg',
    'images/image3.jpeg',
    'images/image4.jpeg',
    'images/image5.jpeg',
    'images/image6.jpeg',
    'images/image7.jpeg',
    'images/image8.jpeg',
    'images/image9.jpeg',
    'images/image10.jpeg',
    'images/image11.jpeg',
    'images/image12.jpeg',
    'images/image13.jpeg',
    'images/image14.jpeg',
    'images/image15.jpeg',
    'images/image16.jpeg',
    'images/image17.jpeg',
    'images/image19.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _searchQuery.isEmpty
        ? _searchableItems
        : _searchableItems
            .where((item) => item['title']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return BasePage(
      currentIndex: 0, // Set index for Home tab
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/image17.jpeg',
              fit: BoxFit.contain,
            ),
          ),
          title: SizedBox(
            width: double.infinity,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
                  color: Color.fromARGB(255, 41, 209, 47),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Slideshow with PageView
              SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _imagePaths[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
              ),

              SizedBox(height: 30),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: filteredItems.map((item) {
                  return _buildNavButton(context, item['title'], item['page']);
                }).toList(),
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
      height: 100,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color.fromARGB(255, 38, 151, 42)),
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
      width: 375,
      height: 100,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FinancialRecordsPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
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
