import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final List<Map<String, dynamic>> _reminders = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  void _addOrEditReminder({int? index}) {
    final isEditing = index != null;

    showDialog(
      context: context,
      builder: (context) {
        if (isEditing) {
          _titleController.text = _reminders[index!]['title'];
          _timeController.text = _reminders[index]['time'];
        } else {
          _titleController.clear();
          _timeController.clear();
        }

        return AlertDialog(
          title: Text(isEditing ? 'Edit Reminder' : 'Add Reminder'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Reminder Title'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title cannot be empty'
                      : null,
                ),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Time (e.g., 2024-12-01 10:00 AM)'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Time cannot be empty'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newReminder = {
                    'title': _titleController.text,
                    'time': _timeController.text,
                  };

                  if (_reminders.any((reminder) =>
                  reminder['title'] == newReminder['title'] &&
                      reminder['time'] == newReminder['time'])) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Duplicate reminder!')),
                    );
                  } else {
                    setState(() {
                      if (isEditing) {
                        _reminders[index!] = newReminder;
                      } else {
                        _reminders.add(newReminder);
                      }
                    });
                    Navigator.pop(context);
                    _scheduleSmsReminder(newReminder);
                  }
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
  }

  Future<void> _scheduleSmsReminder(Map<String, dynamic> reminder) async {
    final message =
        'Reminder: ${reminder['title']} is scheduled for ${reminder['time']}';
    final phoneNumber = ''; // Add recipient phone number here
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send SMS')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _reminders.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No reminders found!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addOrEditReminder(),
              child: const Text('Add Reminder'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                reminder['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(reminder['time']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),  // Changed to black
                    onPressed: () => _addOrEditReminder(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),  // Changed to black
                    onPressed: () => _deleteReminder(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditReminder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
