import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class BasePage extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const BasePage({
    Key? key,
    required this.currentIndex,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTabSelected: (index) {
          _onTabSelected(context, index);
        },
      ),
    );
  }

  void _onTabSelected(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 2:
        _handleLogout(context);
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully")),
    );
    // Add any additional logout logic here.
  }
}
