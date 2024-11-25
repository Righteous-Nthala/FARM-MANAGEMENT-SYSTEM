import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class PesticidesRecordsPage extends StatefulWidget {
  const PesticidesRecordsPage({Key? key}) : super(key: key);

  @override
  _PesticidesRecordsPageState createState() => _PesticidesRecordsPageState();
}

class _PesticidesRecordsPageState extends State<PesticidesRecordsPage> {
  final CollectionReference pesticidesRecordsCollection =
  FirebaseFirestore.instance.collection('pesticides_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesticides Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: pesticidesRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No pesticides records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddPesticidesRecordDialog,
                    child: const Text("Add Pesticides Record"),
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
                    DataColumn(label: Center(child: Text("Type"))),
                    DataColumn(label: Center(child: Text("Quantity"))),
                    DataColumn(label: Center(child: Text("Application Date"))),
                    DataColumn(label: Center(child: Text("Crop"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String type = data['type'];
                    final String quantity = data['quantity'];
                    final String applicationDate = data['application_date'];
                    final String crop = data['crop'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey[350]!
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(type))),
                        DataCell(Center(child: Text(quantity))),
                        DataCell(Center(child: Text(applicationDate))),
                        DataCell(Center(child: Text(crop))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddPesticidesRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                type: type,
                                quantity: quantity,
                                applicationDate: applicationDate,
                                crop: crop,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deletePesticidesRecord(doc.id),
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
        onPressed: _showAddPesticidesRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddPesticidesRecordDialog({
    String action = 'Add',
    String? docId,
    String type = '',
    String quantity = '',
    String applicationDate = '',
    String crop = '',
  }) async {
    final _typeController = TextEditingController(text: type);
    final _quantityController = TextEditingController(text: quantity);
    final _applicationDateController = TextEditingController(text: applicationDate);
    final _cropController = TextEditingController(text: crop);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Pesticides Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: "Type"),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
              ),
              TextField(
                controller: _applicationDateController,
                decoration: const InputDecoration(labelText: "Application Date"),
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
              String type = _typeController.text.trim();
              String quantity = _quantityController.text.trim();
              String applicationDate = _applicationDateController.text.trim();
              String crop = _cropController.text.trim();

              if (type.isEmpty || quantity.isEmpty || applicationDate.isEmpty || crop.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate row before adding
              final duplicateExists = await _checkForDuplicatePesticidesRecord(
                  type, quantity, applicationDate, crop, docId);

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addPesticidesRecord(type, quantity, applicationDate, crop);
              } else {
                await _editPesticidesRecord(docId!, type, quantity, applicationDate, crop);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addPesticidesRecord(String type, String quantity, String applicationDate, String crop) async {
    await pesticidesRecordsCollection.add({
      'type': type,
      'quantity': quantity,
      'application_date': applicationDate,
      'crop': crop,
    });
  }

  Future<void> _editPesticidesRecord(String docId, String type, String quantity, String applicationDate, String crop) async {
    await pesticidesRecordsCollection.doc(docId).update({
      'type': type,
      'quantity': quantity,
      'application_date': applicationDate,
      'crop': crop,
    });
  }

  Future<void> _deletePesticidesRecord(String docId) async {
    await pesticidesRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicatePesticidesRecord(
      String type, String quantity, String applicationDate, String crop, String? docId) async {
    final querySnapshot = await pesticidesRecordsCollection
        .where('type', isEqualTo: type)
        .where('quantity', isEqualTo: quantity)
        .where('application_date', isEqualTo: applicationDate)
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
