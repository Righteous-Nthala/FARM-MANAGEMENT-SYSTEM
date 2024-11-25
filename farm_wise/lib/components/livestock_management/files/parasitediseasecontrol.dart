import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class ParasiteDiseaseControlPage extends StatefulWidget {
  const ParasiteDiseaseControlPage({Key? key}) : super(key: key);

  @override
  _ParasiteDiseaseControlPageState createState() =>
      _ParasiteDiseaseControlPageState();
}

class _ParasiteDiseaseControlPageState
    extends State<ParasiteDiseaseControlPage> {
  final CollectionReference parasiteDiseaseControlCollection =
  FirebaseFirestore.instance.collection('parasite_disease_control');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parasite & Disease Control',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: parasiteDiseaseControlCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No parasite or disease control records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddControlRecordDialog,
                    child: const Text("Add Control Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Center(child: Text("No"))),
                  DataColumn(label: Center(child: Text("Date"))),
                  DataColumn(label: Center(child: Text("Treatment Type"))),
                  DataColumn(label: Center(child: Text("Target"))),
                  DataColumn(label: Center(child: Text("Severity"))),
                  DataColumn(label: Center(child: Text("Veterinary"))),
                  DataColumn(label: Center(child: Text("Animal + ID"))),
                  DataColumn(label: Center(child: Text("Actions"))),
                ],
                rows: List.generate(snapshot.data!.docs.length, (index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String date = data['date'] ?? '';
                  final String treatmentType = data['treatment_type'] ?? '';
                  final String target = data['target'] ?? '';
                  final String severity = data['severity'] ?? '';
                  final String veterinary = data['veterinary'] ?? '';
                  final String animalId = data['animal_id'] ?? '';

                  return DataRow(
                    color: MaterialStateProperty.resolveWith(
                          (states) => Colors.grey[350]!, // Set gray background color
                    ),
                    cells: [
                      DataCell(Center(child: Text('${index + 1}'))),
                      DataCell(Center(child: Text(date))),
                      DataCell(Center(child: Text(treatmentType))),
                      DataCell(Center(child: Text(target))),
                      DataCell(Center(child: Text(severity))),
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
                              date: date,
                              treatmentType: treatmentType,
                              target: target,
                              severity: severity,
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
                }),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddControlRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddControlRecordDialog({
    String action = 'Add',
    String? docId,
    String date = '',
    String treatmentType = '',
    String target = '',
    String severity = '',
    String veterinary = '',
    String animalId = '',
  }) async {
    final _dateController = TextEditingController(text: date);
    final _treatmentTypeController = TextEditingController(text: treatmentType);
    final _targetController = TextEditingController(text: target);
    final _severityController = TextEditingController(text: severity);
    final _veterinaryController = TextEditingController(text: veterinary);
    final _animalIdController = TextEditingController(text: animalId);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Control Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
              TextField(
                controller: _treatmentTypeController,
                decoration: const InputDecoration(labelText: "Treatment Type"),
              ),
              TextField(
                controller: _targetController,
                decoration: const InputDecoration(labelText: "Target"),
              ),
              TextField(
                controller: _severityController,
                decoration: const InputDecoration(labelText: "Severity"),
              ),
              TextField(
                controller: _veterinaryController,
                decoration: const InputDecoration(labelText: "Veterinary"),
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
              Navigator.pop(context);
              final String date = _dateController.text.trim();
              final String treatmentType = _treatmentTypeController.text.trim();
              final String target = _targetController.text.trim();
              final String severity = _severityController.text.trim();
              final String veterinary = _veterinaryController.text.trim();
              final String animalId = _animalIdController.text.trim();

              if (date.isEmpty ||
                  treatmentType.isEmpty ||
                  target.isEmpty ||
                  severity.isEmpty ||
                  veterinary.isEmpty ||
                  animalId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              if (action == 'Add') {
                await _addControlRecord(
                    date, treatmentType, target, severity, veterinary, animalId);
              } else {
                await _editControlRecord(docId!, date, treatmentType, target,
                    severity, veterinary, animalId);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addControlRecord(String date, String treatmentType,
      String target, String severity, String veterinary, String animalId) async {
    await parasiteDiseaseControlCollection.add({
      'date': date,
      'treatment_type': treatmentType,
      'target': target,
      'severity': severity,
      'veterinary': veterinary,
      'animal_id': animalId,
    });
  }

  Future<void> _editControlRecord(String docId, String date,
      String treatmentType, String target, String severity, String veterinary, String animalId) async {
    await parasiteDiseaseControlCollection.doc(docId).update({
      'date': date,
      'treatment_type': treatmentType,
      'target': target,
      'severity': severity,
      'veterinary': veterinary,
      'animal_id': animalId,
    });
  }

  Future<void> _deleteControlRecord(String docId) async {
    await parasiteDiseaseControlCollection.doc(docId).delete();
  }
}
