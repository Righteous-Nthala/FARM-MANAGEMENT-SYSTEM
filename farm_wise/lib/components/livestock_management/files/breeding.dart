import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BreedingPage extends StatefulWidget {
  const BreedingPage({super.key});

  @override
  State<BreedingPage> createState() => _BreedingPageState();
}

class _BreedingPageState extends State<BreedingPage> {
  final CollectionReference breedingCollection = FirebaseFirestore.instance.collection('breeding_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding Records'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: breedingCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No breeding records found", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showAddBreedingDialog(),
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
                  DataColumn(label: Text("Animal ID")),
                  DataColumn(label: Text("Breeding Method")),
                  DataColumn(label: Text("Partner")),
                  DataColumn(label: Text("Pregnancy Date")),
                  DataColumn(label: Text("Delivery Date")),
                  DataColumn(label: Text("Offspring ID")),
                  DataColumn(label: Text("Offspring Gender")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(data['animal_id'] ?? '')),
                    DataCell(Text(data['breeding_method'] ?? '')),
                    DataCell(Text(data['partner'] ?? '')),
                    DataCell(Text(data['pregnancy_date'] ?? '')),
                    DataCell(Text(data['delivery_date'] ?? '')),
                    DataCell(Text(data['offspring_id'] ?? '')),
                    DataCell(Text(data['offspring_gender'] ?? '')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditBreedingDialog(doc.id, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteBreedingRecord(doc.id),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBreedingDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddBreedingDialog() async {
    final TextEditingController animalIdController = TextEditingController();
    final TextEditingController methodController = TextEditingController();
    final TextEditingController partnerController = TextEditingController();
    final TextEditingController pregnancyDateController = TextEditingController();
    final TextEditingController deliveryDateController = TextEditingController();
    final TextEditingController offspringIdController = TextEditingController();
    final TextEditingController genderController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Breeding Record"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: animalIdController, decoration: const InputDecoration(labelText: "Animal ID")),
              TextField(controller: methodController, decoration: const InputDecoration(labelText: "Breeding Method")),
              TextField(controller: partnerController, decoration: const InputDecoration(labelText: "Partner")),
              TextField(controller: pregnancyDateController, decoration: const InputDecoration(labelText: "Pregnancy Date")),
              TextField(controller: deliveryDateController, decoration: const InputDecoration(labelText: "Delivery Date")),
              TextField(controller: offspringIdController, decoration: const InputDecoration(labelText: "Offspring ID")),
              TextField(controller: genderController, decoration: const InputDecoration(labelText: "Offspring Gender")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _addBreedingRecord({
                'animal_id': animalIdController.text,
                'breeding_method': methodController.text,
                'partner': partnerController.text,
                'pregnancy_date': pregnancyDateController.text,
                'delivery_date': deliveryDateController.text,
                'offspring_id': offspringIdController.text,
                'offspring_gender': genderController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBreedingDialog(String docId, Map<String, dynamic> data) async {
    final TextEditingController animalIdController = TextEditingController(text: data['animal_id']);
    final TextEditingController methodController = TextEditingController(text: data['breeding_method']);
    final TextEditingController partnerController = TextEditingController(text: data['partner']);
    final TextEditingController pregnancyDateController = TextEditingController(text: data['pregnancy_date']);
    final TextEditingController deliveryDateController = TextEditingController(text: data['delivery_date']);
    final TextEditingController offspringIdController = TextEditingController(text: data['offspring_id']);
    final TextEditingController genderController = TextEditingController(text: data['offspring_gender']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Breeding Record"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: animalIdController, decoration: const InputDecoration(labelText: "Animal ID")),
              TextField(controller: methodController, decoration: const InputDecoration(labelText: "Breeding Method")),
              TextField(controller: partnerController, decoration: const InputDecoration(labelText: "Partner")),
              TextField(controller: pregnancyDateController, decoration: const InputDecoration(labelText: "Pregnancy Date")),
              TextField(controller: deliveryDateController, decoration: const InputDecoration(labelText: "Delivery Date")),
              TextField(controller: offspringIdController, decoration: const InputDecoration(labelText: "Offspring ID")),
              TextField(controller: genderController, decoration: const InputDecoration(labelText: "Offspring Gender")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _editBreedingRecord(docId, {
                'animal_id': animalIdController.text,
                'breeding_method': methodController.text,
                'partner': partnerController.text,
                'pregnancy_date': pregnancyDateController.text,
                'delivery_date': deliveryDateController.text,
                'offspring_id': offspringIdController.text,
                'offspring_gender': genderController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addBreedingRecord(Map<String, dynamic> data) async {
    await breedingCollection.add(data);
  }

  Future<void> _editBreedingRecord(String docId, Map<String, dynamic> data) async {
    await breedingCollection.doc(docId).update(data);
  }

  Future<void> _deleteBreedingRecord(String docId) async {
    await breedingCollection.doc(docId).delete();
  }
}
