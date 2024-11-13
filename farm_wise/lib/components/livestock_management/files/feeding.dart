import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingRecordsPage extends StatefulWidget {
  @override
  _FeedingRecordsPageState createState() => _FeedingRecordsPageState();
}

class _FeedingRecordsPageState extends State<FeedingRecordsPage> {
  final CollectionReference feedingsCollection =
  FirebaseFirestore.instance.collection('feedings');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Records'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: feedingsCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No feeding records found.'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Food Type')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Animal')),
                      DataColumn(label: Text('Labor')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DataRow(
                        cells: [
                          DataCell(Text(data['date'] ?? '')),
                          DataCell(Text(data['time'] ?? '')),
                          DataCell(Text(data['food_type'] ?? '')),
                          DataCell(Text(data['amount'].toString())),
                          DataCell(Text(data['animal'] ?? '')),
                          DataCell(Text(data['labor'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(doc.id, data),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteFeeding(doc.id),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddDialog,
              child: Text('Add Feeding Record'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    String date = '';
    String time = '';
    String foodType = '';
    int amount = 0;
    String animal = '';
    String labor = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Feeding Record'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Date', (value) => date = value),
              _buildTextField('Time', (value) => time = value),
              _buildTextField('Food Type', (value) => foodType = value),
              _buildTextField('Amount', (value) => amount = int.tryParse(value) ?? 0),
              _buildTextField('Animal', (value) => animal = value),
              _buildTextField('Labor', (value) => labor = value),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (date.isNotEmpty && foodType.isNotEmpty && animal.isNotEmpty) {
                await feedingsCollection.add({
                  'date': date,
                  'time': time,
                  'food_type': foodType,
                  'amount': amount,
                  'animal': animal,
                  'labor': labor,
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> data) {
    String date = data['date'];
    String time = data['time'];
    String foodType = data['food_type'];
    int amount = data['amount'];
    String animal = data['animal'];
    String labor = data['labor'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Feeding Record'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Date', (value) => date = value, initialValue: date),
              _buildTextField('Time', (value) => time = value, initialValue: time),
              _buildTextField('Food Type', (value) => foodType = value, initialValue: foodType),
              _buildTextField('Amount', (value) => amount = int.tryParse(value) ?? amount, initialValue: amount.toString()),
              _buildTextField('Animal', (value) => animal = value, initialValue: animal),
              _buildTextField('Labor', (value) => labor = value, initialValue: labor),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await feedingsCollection.doc(docId).update({
                'date': date,
                'time': time,
                'food_type': foodType,
                'amount': amount,
                'animal': animal,
                'labor': labor,
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteFeeding(String docId) async {
    await feedingsCollection.doc(docId).delete();
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String? initialValue}) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}
