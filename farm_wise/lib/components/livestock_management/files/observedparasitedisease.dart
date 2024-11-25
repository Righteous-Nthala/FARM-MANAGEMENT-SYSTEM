import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class ParasiteDiseaseRecordsPage extends StatefulWidget {
  const ParasiteDiseaseRecordsPage({Key? key}) : super(key: key);

  @override
  _ParasiteDiseaseRecordsPageState createState() =>
      _ParasiteDiseaseRecordsPageState();
}

class _ParasiteDiseaseRecordsPageState
    extends State<ParasiteDiseaseRecordsPage> {
  final CollectionReference parasiteDiseaseRecordsCollection =
  FirebaseFirestore.instance.collection('parasite_disease_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parasite & Disease Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: parasiteDiseaseRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No parasite or disease records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddParasiteDiseaseRecordDialog,
                    child: const Text("Add Parasite/Disease Record"),
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
                    DataColumn(label: Center(child: Text("No"))),
                    DataColumn(label: Center(child: Text("Parasite/Disease"))),
                    DataColumn(label: Center(child: Text("Severity"))),
                    DataColumn(label: Center(child: Text("Date Observed"))),
                    DataColumn(label: Center(child: Text("Animal + ID"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String parasiteDisease = data['parasite_disease'];
                    final String severity = data['severity'];
                    final String dateObserved = data['date_observed'];
                    final String animalId = data['animal_id'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey[350]!),
                      cells: [
                        DataCell(Center(child: Text('${index + 1}'))),  // Row number (No)
                        DataCell(Center(child: Text(parasiteDisease))),
                        DataCell(Center(child: Text(severity))),
                        DataCell(Center(child: Text(dateObserved))),
                        DataCell(Center(child: Text(animalId))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddParasiteDiseaseRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                parasiteDisease: parasiteDisease,
                                severity: severity,
                                dateObserved: dateObserved,
                                animalId: animalId,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteParasiteDiseaseRecord(doc.id),
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
        onPressed: _showAddParasiteDiseaseRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddParasiteDiseaseRecordDialog({
    String action = 'Add',
    String? docId,
    String parasiteDisease = '',
    String severity = '',
    String dateObserved = '',
    String animalId = '',
  }) async {
    final _parasiteDiseaseController = TextEditingController(text: parasiteDisease);
    final _severityController = TextEditingController(text: severity);
    final _dateObservedController = TextEditingController(text: dateObserved);
    final _animalIdController = TextEditingController(text: animalId);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Parasite/Disease Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _parasiteDiseaseController,
                decoration: const InputDecoration(labelText: "Parasite/Disease"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _severityController,
                decoration: const InputDecoration(labelText: "Severity"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _dateObservedController,
                decoration: const InputDecoration(labelText: "Date Observed"),
              ),
              TextField(
                controller: _animalIdController,
                decoration: const InputDecoration(labelText: "Animal ID"),
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
              String parasiteDisease = _capitalizeFirstLetter(_parasiteDiseaseController.text.trim());
              String severity = _capitalizeFirstLetter(_severityController.text.trim());
              String dateObserved = _dateObservedController.text.trim();
              String animalId = _animalIdController.text.trim();

              if (parasiteDisease.isEmpty || severity.isEmpty || dateObserved.isEmpty || animalId.isEmpty) {
                // Show an error if any field is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              bool duplicateExists = await _checkForDuplicateParasiteDiseaseRecord(
                  parasiteDisease, severity, dateObserved, animalId, docId
              );

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addParasiteDiseaseRecord(parasiteDisease, severity, dateObserved, animalId);
              } else {
                await _editParasiteDiseaseRecord(docId!, parasiteDisease, severity, dateObserved, animalId);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  Future<void> _addParasiteDiseaseRecord(
      String parasiteDisease, String severity, String dateObserved, String animalId) async {
    await parasiteDiseaseRecordsCollection.add({
      'parasite_disease': parasiteDisease,
      'severity': severity,
      'date_observed': dateObserved,
      'animal_id': animalId,
    });
  }

  Future<void> _editParasiteDiseaseRecord(
      String docId, String parasiteDisease, String severity, String dateObserved, String animalId) async {
    await parasiteDiseaseRecordsCollection.doc(docId).update({
      'parasite_disease': parasiteDisease,
      'severity': severity,
      'date_observed': dateObserved,
      'animal_id': animalId,
    });
  }

  Future<void> _deleteParasiteDiseaseRecord(String docId) async {
    await parasiteDiseaseRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateParasiteDiseaseRecord(
      String parasiteDisease, String severity, String dateObserved, String animalId, String? docId) async {
    final querySnapshot = await parasiteDiseaseRecordsCollection
        .where('parasite_disease', isEqualTo: parasiteDisease)
        .where('severity', isEqualTo: severity)
        .where('date_observed', isEqualTo: dateObserved)
        .where('animal_id', isEqualTo: animalId)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicates
  }
}
