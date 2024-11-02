import 'package:flutter/material.dart';
import 'package:farm_wise/components/home_page.dart';
import 'notifications_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTabSelected});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Prevent reloading the same page

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
        break;
      case 2:
        // Handle logout action
        _handleLogout(context);
        break;
    }
    onTabSelected(index);
  }

  void _handleLogout(BuildContext context) {
    // Replace this with your logout logic.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logged out successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: Colors.green, // Set background color to green
      selectedItemColor: Colors.white, // White color for selected items
      unselectedItemColor: Colors.white70, // Lighter color for unselected items
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Remainders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}
