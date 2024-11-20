import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalTypePage extends StatefulWidget {
  final String animalName;

  const AnimalTypePage({Key? key, required this.animalName}) : super(key: key);

  @override
  State<AnimalTypePage> createState() => _AnimalTypePageState();
}

class _AnimalTypePageState extends State<AnimalTypePage> {
  final CollectionReference animalRecords =
  FirebaseFirestore.instance.collection('animalRecords');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.animalName} Details',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: animalRecords
            .where('animal_name', isEqualTo: widget.animalName)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showAddOrEditRecordDialog('Add'),
                    child: const Text("Add Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView( // Make the whole body scrollable
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView( // Allow horizontal scrolling
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Center(child: Text("Row #"))),
                    DataColumn(label: Center(child: Text("ID"))),  // Swapped ID and Breed columns
                    DataColumn(label: Center(child: Text("Breed"))),  // Swapped Breed and ID columns
                    DataColumn(label: Center(child: Text("Gender"))),
                    DataColumn(label: Center(child: Text("Birth Date"))),
                    DataColumn(label: Center(child: Text("Acquisition Date"))),
                    DataColumn(label: Center(child: Text("Origin"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: snapshot.data!.docs.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final doc = entry.value;
                    final data = doc.data() as Map<String, dynamic>;

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                              (states) => index % 2 == 0
                              ? Colors.grey[200]
                              : Colors.white),
                      cells: [
                        DataCell(Center(child: Text(index.toString()))),
                        DataCell(Center(child: Text(data['id'] ?? 'Unknown'))),  // Swapped ID and Breed data
                        DataCell(Center(child: Text(data['breed'] ?? 'Unknown'))),  // Swapped Breed and ID data
                        DataCell(Center(child: Text(data['gender'] ?? 'Unknown'))),
                        DataCell(Center(child: Text(data['birth_date'] ?? 'Unknown'))),
                        DataCell(Center(child: Text(data['acquisition_date'] ?? 'Unknown'))),
                        DataCell(Center(child: Text(data['origin'] ?? 'Unknown'))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _showAddOrEditRecordDialog('Edit', doc: doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteRecord(doc.id),
                              ),
                            ],
                          ),
                        ),
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
        onPressed: () => _showAddOrEditRecordDialog('Add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddOrEditRecordDialog(String action,
      {DocumentSnapshot? doc}) async {
    final docId = doc?.id;
    String breed = doc?['breed'] ?? "";
    String animalId = doc?['id'] ?? "";
    String gender = doc?['gender'] ?? "";
    String birthDate = doc?['birth_date'] ?? "";
    String acquisitionDate = doc?['acquisition_date'] ?? "";
    String origin = doc?['origin'] ?? "";

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Record"),
        content: SingleChildScrollView( // Wrap content in SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: animalId),
                onChanged: (value) => animalId = value,
                decoration: const InputDecoration(labelText: "ID"),
              ),
              TextField(
                controller: TextEditingController(text: breed),
                onChanged: (value) => breed = value,
                decoration: const InputDecoration(labelText: "Breed"),
              ),
              TextField(
                controller: TextEditingController(text: gender),
                onChanged: (value) => gender = value,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextField(
                controller: TextEditingController(text: birthDate),
                onChanged: (value) => birthDate = value,
                decoration: const InputDecoration(labelText: "Birth Date"),
              ),
              TextField(
                controller: TextEditingController(text: acquisitionDate),
                onChanged: (value) => acquisitionDate = value,
                decoration: const InputDecoration(labelText: "Acquisition Date"),
              ),
              TextField(
                controller: TextEditingController(text: origin),
                onChanged: (value) => origin = value,
                decoration: const InputDecoration(labelText: "Origin"),
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
              Navigator.pop(context); // Close dialog first
              if (animalId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ID cannot be empty")),
                );
                return;
              }

              // Check for duplicate IDs
              final isDuplicate = await _checkForDuplicateId(animalId, docId);
              if (isDuplicate) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("ID '$animalId' already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addRecord(breed, animalId, gender, birthDate,
                    acquisitionDate, origin);
              } else {
                await _editRecord(docId!, breed, animalId, gender, birthDate,
                    acquisitionDate, origin);
              }

              // Trigger a rebuild of the UI after adding or editing
              setState(() {});
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecord(String breed, String animalId, String gender,
      String birthDate, String acquisitionDate, String origin) async {
    await animalRecords.add({
      'animal_name': widget.animalName,  // Make sure animal name is included
      'breed': breed,
      'id': animalId,
      'gender': gender,
      'birth_date': birthDate,
      'acquisition_date': acquisitionDate,
      'origin': origin,
    });
  }

  Future<void> _editRecord(
      String docId,
      String breed,
      String animalId,
      String gender,
      String birthDate,
      String acquisitionDate,
      String origin) async {
    await animalRecords.doc(docId).update({
      'animal_name': widget.animalName,  // Make sure animal name is included
      'breed': breed,
      'id': animalId,
      'gender': gender,
      'birth_date': birthDate,
      'acquisition_date': acquisitionDate,
      'origin': origin,
    });
  }

  Future<void> _deleteRecord(String docId) async {
    await animalRecords.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateId(String id, String? docId) async {
    final query = await animalRecords.where('id', isEqualTo: id).get();
    for (var doc in query.docs) {
      if (doc.id != docId) {
        return true;
      }
    }
    return false;
  }
}
