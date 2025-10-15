import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final notificationsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return BasePage(
      currentIndex: 1,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: notificationsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              actions: [
                IconButton(
                  tooltip: 'Add test notification',
                  icon: const Icon(Icons.add_alert),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('notifications')
                        .add({
                      'title': 'Test notification',
                      'body': 'This is a local test entry.',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  },
                ),
              ],
            ),
            body: docs.isEmpty
                ? const Center(child: Text('No new notifications.'))
                : ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(data['title'] ?? 'Notification'),
                        subtitle: Text(data['body'] ?? ''),
                        trailing: Text(
                          (data['createdAt'] as Timestamp?)?.toDate().toLocal().toString().split('.').first ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
