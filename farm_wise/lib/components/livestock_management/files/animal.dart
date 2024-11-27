import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/livestock_management/files/animaltype.dart';

class Animal extends StatefulWidget {
  const Animal({super.key});

  @override
  State<Animal> createState() => _AnimalState();
}

class _AnimalState extends State<Animal> {
  final CollectionReference animalsCollection =
  FirebaseFirestore.instance.collection('animals');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Animals',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: animalsCollection.orderBy('name').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No animals found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddAnimalDialog,
                    child: const Text("Add Animal"),
                  ),
                ],
              ),
            );
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String animalName = data['name'] ?? 'Unnamed Animal';
                final String formattedName = _capitalize(animalName);

                return Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      formattedName,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
                    ),
                    onTap: () {
                      // Navigate to the specific animal's detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalTypePage(animalName: formattedName),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditAnimalDialog(doc),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAnimal(doc.id),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnimalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _capitalize(String name) {
    return name
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _showAddAnimalDialog() async {
    String animalType = "Poultry";
    String animalName = "";

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Animal"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: animalType,
                  items: ["Poultry", "Non-Poultry"]
                      .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => animalType = value!),
                  decoration: const InputDecoration(labelText: "Animal Type"),
                ),
                TextField(
                  onChanged: (value) => animalName = value,
                  decoration: const InputDecoration(labelText: "Animal Name"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog first
                  if (animalName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Animal name cannot be empty")),
                    );
                    return;
                  }

                  final animalExists =
                  await _checkAnimalExists(animalType, animalName);

                  if (animalExists) {
                    _showAnimalExistsMessage(animalName);
                  } else {
                    await _addAnimal(animalType, animalName);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _checkAnimalExists(String type, String name) async {
    final querySnapshot = await animalsCollection
        .where('type', isEqualTo: type)
        .where('name', isEqualTo: name)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _addAnimal(String type, String name) async {
    await animalsCollection.add({
      'type': type,
      'name': name,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Animal added successfully")),
    );
  }

  Future<void> _showEditAnimalDialog(DocumentSnapshot doc) async {
    String animalType = doc['type'];
    String animalName = doc['name'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Animal"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: animalType,
                  items: ["Poultry", "Non-Poultry"]
                      .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => animalType = value!),
                  decoration: const InputDecoration(labelText: "Animal Type"),
                ),
                TextField(
                  controller: TextEditingController(text: animalName),
                  onChanged: (value) => animalName = value,
                  decoration: const InputDecoration(labelText: "Animal Name"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog first
                  if (animalName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Animal name cannot be empty")),
                    );
                    return;
                  }

                  await _updateAnimal(doc.id, animalType, animalName);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateAnimal(
      String docId, String type, String name) async {
    await animalsCollection.doc(docId).update({
      'type': type,
      'name': name,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Animal updated successfully")),
    );
  }

  Future<void> _deleteAnimal(String docId) async {
    await animalsCollection.doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Animal deleted successfully")),
    );
  }

  void _showAnimalExistsMessage(String animalName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text('$animalName already exists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
