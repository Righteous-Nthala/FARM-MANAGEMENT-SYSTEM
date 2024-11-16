import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParasiteDiseaseControlPage extends StatefulWidget {
  const ParasiteDiseaseControlPage({Key? key}) : super(key: key);

  @override
  _ParasiteDiseaseControlPageState createState() => _ParasiteDiseaseControlPageState();
}

class _ParasiteDiseaseControlPageState extends State<ParasiteDiseaseControlPage> {
  final CollectionReference controlRecordsCollection =
  FirebaseFirestore.instance.collection('parasite_disease_control');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parasite and Disease Control Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: controlRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddControlRecordDialog,
                    child: const Text("Add Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Center(child: Text("No"))),
                    DataColumn(label: Center(child: Text("Treatment Type"))),
                    DataColumn(label: Center(child: Text("Target"))),
                    DataColumn(label: Center(child: Text("Veterinary"))),
                    DataColumn(label: Center(child: Text("Animal + ID"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String treatmentType = data['treatment_type'];
                    final String target = data['target'];
                    final String veterinary = data['veterinary'];
                    final String animalId = data['animal_id'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[200],
                      ),
                      cells: [
                        DataCell(Center(child: Text((snapshot.data!.docs.indexOf(doc) + 1).toString()))),
                        DataCell(Center(child: Text(treatmentType))),
                        DataCell(Center(child: Text(target))),
                        DataCell(Center(child: Text(veterinary))),
                        DataCell(Center(child: Text(animalId))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddControlRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                treatmentType: treatmentType,
                                target: target,
                                veterinary: veterinary,
                                animalId: animalId,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteControlRecord(doc.id),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddControlRecordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddControlRecordDialog({
    String action = 'Add',
    String? docId,
    String treatmentType = '',
    String target = '',
    String veterinary = '',
    String animalId = '',
  }) async {
    final _treatmentTypeController = TextEditingController(text: treatmentType);
    final _targetController = TextEditingController(text: target);
    final _veterinaryController = TextEditingController(text: veterinary);
    final _animalIdController = TextEditingController(text: animalId);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _treatmentTypeController,
                decoration: const InputDecoration(labelText: "Treatment Type"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _targetController,
                decoration: const InputDecoration(labelText: "Target"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _veterinaryController,
                decoration: const InputDecoration(labelText: "Veterinary"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _animalIdController,
                decoration: const InputDecoration(labelText: "Animal + ID"),
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
              String treatmentType = _capitalizeFirstLetter(_treatmentTypeController.text.trim());
              String target = _capitalizeFirstLetter(_targetController.text.trim());
              String veterinary = _capitalizeFirstLetter(_veterinaryController.text.trim());
              String animalId = _animalIdController.text.trim();

              if (action == 'Add') {
                await _addControlRecord(treatmentType, target, veterinary, animalId);
              } else {
                await _editControlRecord(docId!, treatmentType, target, veterinary, animalId);
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

  Future<void> _addControlRecord(
      String treatmentType,
      String target,
      String veterinary,
      String animalId,
      ) async {
    await controlRecordsCollection.add({
      'treatment_type': treatmentType,
      'target': target,
      'veterinary': veterinary,
      'animal_id': animalId,
    });
  }

  Future<void> _editControlRecord(
      String docId,
      String treatmentType,
      String target,
      String veterinary,
      String animalId,
      ) async {
    await controlRecordsCollection.doc(docId).update({
      'treatment_type': treatmentType,
      'target': target,
      'veterinary': veterinary,
      'animal_id': animalId,
    });
  }

  Future<void> _deleteControlRecord(String docId) async {
    await controlRecordsCollection.doc(docId).delete();
  }
}
