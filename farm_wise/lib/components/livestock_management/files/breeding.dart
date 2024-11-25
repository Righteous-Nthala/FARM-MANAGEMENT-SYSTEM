import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class BreedingRecordsPage extends StatefulWidget {
  const BreedingRecordsPage({Key? key}) : super(key: key);

  @override
  _BreedingRecordsPageState createState() => _BreedingRecordsPageState();
}

class _BreedingRecordsPageState extends State<BreedingRecordsPage> {
  final CollectionReference breedingRecordsCollection =
  FirebaseFirestore.instance.collection('breeding_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Breeding Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: breedingRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No breeding records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddBreedingRecordDialog,
                    child: const Text("Add Breeding Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Center(child: Text("No."))),
                  DataColumn(label: Center(child: Text("ID"))),
                  DataColumn(label: Center(child: Text("Animal Type"))),
                  DataColumn(label: Center(child: Text("Breeding Method"))),
                  DataColumn(label: Center(child: Text("Partner Breed"))),
                  DataColumn(label: Center(child: Text("Pregnancy Date"))),
                  DataColumn(label: Center(child: Text("Delivery Date"))),
                  DataColumn(label: Center(child: Text("Offspring ID"))),
                  DataColumn(label: Center(child: Text("Offspring Breed"))),
                  DataColumn(label: Center(child: Text("Offspring Gender"))),
                  DataColumn(label: Center(child: Text("Offspring Status"))),
                  DataColumn(label: Center(child: Text("Actions"))),
                ],
                rows: snapshot.data!.docs.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith(
                          (states) => Colors.grey[350]!,  // Set background color to gray
                    ),
                    cells: [
                      DataCell(Center(child: Text(index.toString()))),
                      DataCell(Center(child: Text(data['id'] ?? ''))),
                      DataCell(Center(child: Text(data['animal_type'] ?? ''))),
                      DataCell(Center(child: Text(data['breeding_method'] ?? ''))),
                      DataCell(Center(child: Text(data['partner_breed'] ?? ''))),
                      DataCell(Center(child: Text(data['pregnancy_date'] ?? ''))),
                      DataCell(Center(child: Text(data['delivery_date'] ?? ''))),
                      DataCell(Center(child: Text(data['offspring_id'] ?? ''))),
                      DataCell(Center(child: Text(data['offspring_breed'] ?? ''))),
                      DataCell(Center(child: Text(data['offspring_gender'] ?? ''))),
                      DataCell(Center(child: Text(data['offspring_status'] ?? ''))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddBreedingRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                data: data,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteBreedingRecord(doc.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBreedingRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddBreedingRecordDialog({
    String action = 'Add',
    String? docId,
    Map<String, dynamic>? data,
  }) async {
    final _idController = TextEditingController(text: data?['id'] ?? '');
    final _animalTypeController = TextEditingController(text: data?['animal_type'] ?? '');
    final _breedingMethodController = TextEditingController(text: data?['breeding_method'] ?? '');
    final _partnerBreedController = TextEditingController(text: data?['partner_breed'] ?? '');
    final _pregnancyDateController = TextEditingController(text: data?['pregnancy_date'] ?? '');
    final _deliveryDateController = TextEditingController(text: data?['delivery_date'] ?? '');
    final _offspringIdController = TextEditingController(text: data?['offspring_id'] ?? '');
    final _offspringBreedController = TextEditingController(text: data?['offspring_breed'] ?? '');
    final _offspringGenderController = TextEditingController(text: data?['offspring_gender'] ?? '');
    final _offspringStatusController = TextEditingController(text: data?['offspring_status'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Breeding Record"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _idController, decoration: const InputDecoration(labelText: "ID")),
              TextField(controller: _animalTypeController, decoration: const InputDecoration(labelText: "Animal Type")),
              TextField(controller: _breedingMethodController, decoration: const InputDecoration(labelText: "Breeding Method")),
              TextField(controller: _partnerBreedController, decoration: const InputDecoration(labelText: "Partner Breed")),
              TextField(controller: _pregnancyDateController, decoration: const InputDecoration(labelText: "Pregnancy Date")),
              TextField(controller: _deliveryDateController, decoration: const InputDecoration(labelText: "Delivery Date")),
              TextField(controller: _offspringIdController, decoration: const InputDecoration(labelText: "Offspring ID")),
              TextField(controller: _offspringBreedController, decoration: const InputDecoration(labelText: "Offspring Breed")),
              TextField(controller: _offspringGenderController, decoration: const InputDecoration(labelText: "Offspring Gender")),
              TextField(controller: _offspringStatusController, decoration: const InputDecoration(labelText: "Offspring Status")),
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
              final fields = [
                _idController.text.trim(),
                _animalTypeController.text.trim(),
                _breedingMethodController.text.trim(),
                _partnerBreedController.text.trim(),
                _pregnancyDateController.text.trim(),
                _deliveryDateController.text.trim(),
                _offspringIdController.text.trim(),
                _offspringBreedController.text.trim(),
                _offspringGenderController.text.trim(),
                _offspringStatusController.text.trim(),
              ];

              if (fields.any((field) => field.isEmpty)) {
                Navigator.pop(context); // Close dialog first
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              Navigator.pop(context); // Close dialog after validation

              if (action == 'Add') {
                await breedingRecordsCollection.add({
                  'id': _idController.text.trim(),
                  'animal_type': _animalTypeController.text.trim(),
                  'breeding_method': _breedingMethodController.text.trim(),
                  'partner_breed': _partnerBreedController.text.trim(),
                  'pregnancy_date': _pregnancyDateController.text.trim(),
                  'delivery_date': _deliveryDateController.text.trim(),
                  'offspring_id': _offspringIdController.text.trim(),
                  'offspring_breed': _offspringBreedController.text.trim(),
                  'offspring_gender': _offspringGenderController.text.trim(),
                  'offspring_status': _offspringStatusController.text.trim(),
                });
              } else {
                await breedingRecordsCollection.doc(docId).update({
                  'id': _idController.text.trim(),
                  'animal_type': _animalTypeController.text.trim(),
                  'breeding_method': _breedingMethodController.text.trim(),
                  'partner_breed': _partnerBreedController.text.trim(),
                  'pregnancy_date': _pregnancyDateController.text.trim(),
                  'delivery_date': _deliveryDateController.text.trim(),
                  'offspring_id': _offspringIdController.text.trim(),
                  'offspring_breed': _offspringBreedController.text.trim(),
                  'offspring_gender': _offspringGenderController.text.trim(),
                  'offspring_status': _offspringStatusController.text.trim(),
                });
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBreedingRecord(String docId) async {
    await breedingRecordsCollection.doc(docId).delete();
  }
}
