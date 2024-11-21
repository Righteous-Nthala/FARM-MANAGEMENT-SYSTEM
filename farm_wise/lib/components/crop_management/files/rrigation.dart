import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class IrrigationRecordsPage extends StatefulWidget {
  const IrrigationRecordsPage({Key? key}) : super(key: key);

  @override
  _IrrigationRecordsPageState createState() => _IrrigationRecordsPageState();
}

class _IrrigationRecordsPageState extends State<IrrigationRecordsPage> {
  final CollectionReference irrigationRecordsCollection =
  FirebaseFirestore.instance.collection('irrigation_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Irrigation Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: irrigationRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No irrigation records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddIrrigationRecordDialog,
                    child: const Text("Add Irrigation Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(  // Make the table scrollable vertically
              child: SingleChildScrollView(  // Allow horizontal scrolling
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,  // Slight increase in column spacing
                  columns: const [
                    DataColumn(label: Center(child: Text("No."))),
                    DataColumn(label: Center(child: Text("Method"))),
                    DataColumn(label: Center(child: Text("Date"))),
                    DataColumn(label: Center(child: Text("Crop"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String method = data['method'];
                    final String date = data['date'];
                    final String crop = data['crop'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey[350]!
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(method))),
                        DataCell(Center(child: Text(date))),
                        DataCell(Center(child: Text(crop))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddIrrigationRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                method: method,
                                date: date,
                                crop: crop,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteIrrigationRecord(doc.id),
                            ),
                          ],
                        )),
                      ],
                    );
                  }),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIrrigationRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddIrrigationRecordDialog({
    String action = 'Add',
    String? docId,
    String method = '',
    String date = '',
    String crop = '',
  }) async {
    final _methodController = TextEditingController(text: method);
    final _dateController = TextEditingController(text: date);
    final _cropController = TextEditingController(text: crop);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Irrigation Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _methodController,
                decoration: const InputDecoration(labelText: "Method"),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
              TextField(
                controller: _cropController,
                decoration: const InputDecoration(labelText: "Crop"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog first

              // Collecting values from the controllers
              String method = _methodController.text.trim();
              String date = _dateController.text.trim();
              String crop = _cropController.text.trim();

              if (method.isEmpty || date.isEmpty || crop.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate row before adding
              final duplicateExists = await _checkForDuplicateIrrigationRecord(
                  method, date, crop, docId);

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addIrrigationRecord(method, date, crop);
              } else {
                await _editIrrigationRecord(docId!, method, date, crop);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addIrrigationRecord(String method, String date, String crop) async {
    await irrigationRecordsCollection.add({
      'method': method,
      'date': date,
      'crop': crop,
    });
  }

  Future<void> _editIrrigationRecord(String docId, String method, String date, String crop) async {
    await irrigationRecordsCollection.doc(docId).update({
      'method': method,
      'date': date,
      'crop': crop,
    });
  }

  Future<void> _deleteIrrigationRecord(String docId) async {
    await irrigationRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateIrrigationRecord(
      String method, String date, String crop, String? docId) async {
    final querySnapshot = await irrigationRecordsCollection
        .where('method', isEqualTo: method)
        .where('date', isEqualTo: date)
        .where('crop', isEqualTo: crop)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
