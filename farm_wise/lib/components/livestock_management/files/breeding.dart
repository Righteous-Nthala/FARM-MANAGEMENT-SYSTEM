import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BreedingRecordsPage extends StatefulWidget {
  const BreedingRecordsPage({super.key});

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
            return SingleChildScrollView(  // Make the table scrollable vertically
              child: SingleChildScrollView(  // Allow horizontal scrolling
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,  // Slight increase in column spacing
                  columns: const [
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
                  rows: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String id = data['id'];
                    final String animalType = data['animal_type'];
                    final String breedingMethod = data['breeding_method'];
                    final String partnerBreed = data['partner_breed'];
                    final String pregnancyDate = data['pregnancy_date'];
                    final String deliveryDate = data['delivery_date'];
                    final String offspringId = data['offspring_id'];
                    final String offspringBreed = data['offspring_breed'];
                    final String offspringGender = data['offspring_gender'];
                    final String offspringStatus = data['offspring_status'];

                    return DataRow(
                      color: WidgetStateProperty.resolveWith(
                            (states) => Colors.grey[200]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text(id))),
                        DataCell(Center(child: Text(animalType))),
                        DataCell(Center(child: Text(breedingMethod))),
                        DataCell(Center(child: Text(partnerBreed))),
                        DataCell(Center(child: Text(pregnancyDate))),
                        DataCell(Center(child: Text(deliveryDate))),
                        DataCell(Center(child: Text(offspringId))),
                        DataCell(Center(child: Text(offspringBreed))),
                        DataCell(Center(child: Text(offspringGender))),
                        DataCell(Center(child: Text(offspringStatus))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddBreedingRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                id: id,
                                animalType: animalType,
                                breedingMethod: breedingMethod,
                                partnerBreed: partnerBreed,
                                pregnancyDate: pregnancyDate,
                                deliveryDate: deliveryDate,
                                offspringId: offspringId,
                                offspringBreed: offspringBreed,
                                offspringGender: offspringGender,
                                offspringStatus: offspringStatus,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteBreedingRecord(doc.id),
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
        onPressed: _showAddBreedingRecordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddBreedingRecordDialog({
    String action = 'Add',
    String? docId,
    String id = '',
    String animalType = '',
    String breedingMethod = '',
    String partnerBreed = '',
    String pregnancyDate = '',
    String deliveryDate = '',
    String offspringId = '',
    String offspringBreed = '',
    String offspringGender = '',
    String offspringStatus = '',
  }) async {
    final idController = TextEditingController(text: id);
    final animalTypeController = TextEditingController(text: animalType);
    final breedingMethodController = TextEditingController(text: breedingMethod);
    final partnerBreedController = TextEditingController(text: partnerBreed);
    final pregnancyDateController = TextEditingController(text: pregnancyDate);
    final deliveryDateController = TextEditingController(text: deliveryDate);
    final offspringIdController = TextEditingController(text: offspringId);
    final offspringBreedController = TextEditingController(text: offspringBreed);
    final offspringGenderController = TextEditingController(text: offspringGender);
    final offspringStatusController = TextEditingController(text: offspringStatus);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Breeding Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: "ID"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: animalTypeController,
                decoration: const InputDecoration(labelText: "Animal Type"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: breedingMethodController,
                decoration: const InputDecoration(labelText: "Breeding Method"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: partnerBreedController,
                decoration: const InputDecoration(labelText: "Partner Breed"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: pregnancyDateController,
                decoration: const InputDecoration(labelText: "Pregnancy Date"),
              ),
              TextField(
                controller: deliveryDateController,
                decoration: const InputDecoration(labelText: "Delivery Date"),
              ),
              TextField(
                controller: offspringIdController,
                decoration: const InputDecoration(labelText: "Offspring ID"),
              ),
              TextField(
                controller: offspringBreedController,
                decoration: const InputDecoration(labelText: "Offspring Breed"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: offspringGenderController,
                decoration: const InputDecoration(labelText: "Offspring Gender"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: offspringStatusController,
                decoration: const InputDecoration(labelText: "Offspring Status"),
                textCapitalization: TextCapitalization.words,
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
              String id = _capitalizeFirstLetter(idController.text.trim());
              String animalType = _capitalizeFirstLetter(animalTypeController.text.trim());
              String breedingMethod = _capitalizeFirstLetter(breedingMethodController.text.trim());
              String partnerBreed = _capitalizeFirstLetter(partnerBreedController.text.trim());
              String pregnancyDate = pregnancyDateController.text.trim();
              String deliveryDate = deliveryDateController.text.trim();
              String offspringId = offspringIdController.text.trim();
              String offspringBreed = _capitalizeFirstLetter(offspringBreedController.text.trim());
              String offspringGender = _capitalizeFirstLetter(offspringGenderController.text.trim());
              String offspringStatus = _capitalizeFirstLetter(offspringStatusController.text.trim());

              bool duplicateExists = await _checkForDuplicateBreedingRecord(
                  id, animalType, breedingMethod, partnerBreed, pregnancyDate,
                  deliveryDate, offspringId, offspringBreed, offspringGender, offspringStatus, docId
              );

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addBreedingRecord(id, animalType, breedingMethod, partnerBreed, pregnancyDate, deliveryDate, offspringId, offspringBreed, offspringGender, offspringStatus);
              } else {
                await _editBreedingRecord(
                    docId!, id, animalType, breedingMethod, partnerBreed, pregnancyDate, deliveryDate, offspringId, offspringBreed, offspringGender, offspringStatus);
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

  Future<void> _addBreedingRecord(
      String id, String animalType, String breedingMethod, String partnerBreed,
      String pregnancyDate, String deliveryDate, String offspringId, String offspringBreed,
      String offspringGender, String offspringStatus) async {
    await breedingRecordsCollection.add({
      'id': id,
      'animal_type': animalType,
      'breeding_method': breedingMethod,
      'partner_breed': partnerBreed,
      'pregnancy_date': pregnancyDate,
      'delivery_date': deliveryDate,
      'offspring_id': offspringId,
      'offspring_breed': offspringBreed,
      'offspring_gender': offspringGender,
      'offspring_status': offspringStatus,
    });
  }

  Future<void> _editBreedingRecord(
      String docId, String id, String animalType, String breedingMethod, String partnerBreed,
      String pregnancyDate, String deliveryDate, String offspringId, String offspringBreed,
      String offspringGender, String offspringStatus) async {
    await breedingRecordsCollection.doc(docId).update({
      'id': id,
      'animal_type': animalType,
      'breeding_method': breedingMethod,
      'partner_breed': partnerBreed,
      'pregnancy_date': pregnancyDate,
      'delivery_date': deliveryDate,
      'offspring_id': offspringId,
      'offspring_breed': offspringBreed,
      'offspring_gender': offspringGender,
      'offspring_status': offspringStatus,
    });
  }

  Future<void> _deleteBreedingRecord(String docId) async {
    await breedingRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateBreedingRecord(
      String id, String animalType, String breedingMethod, String partnerBreed,
      String pregnancyDate, String deliveryDate, String offspringId, String offspringBreed,
      String offspringGender, String offspringStatus, String? docId) async {
    final querySnapshot = await breedingRecordsCollection
        .where('id', isEqualTo: id)
        .where('animal_type', isEqualTo: animalType)
        .where('breeding_method', isEqualTo: breedingMethod)
        .where('partner_breed', isEqualTo: partnerBreed)
        .where('pregnancy_date', isEqualTo: pregnancyDate)
        .where('delivery_date', isEqualTo: deliveryDate)
        .where('offspring_id', isEqualTo: offspringId)
        .where('offspring_breed', isEqualTo: offspringBreed)
        .where('offspring_gender', isEqualTo: offspringGender)
        .where('offspring_status', isEqualTo: offspringStatus)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicates
  }
}
