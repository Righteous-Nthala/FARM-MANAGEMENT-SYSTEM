import 'package:flutter/material.dart';
import 'base_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      currentIndex: 1, // Set index for Notifications tab
      child: Center(
        child: Text("No new notifications."),
      ),
    );
  }
}
