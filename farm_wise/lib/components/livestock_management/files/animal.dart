import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        stream: animalsCollection.snapshots(),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditAnimalDialog(doc.id, data['type'], formattedName),
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
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Future<void> _showAddAnimalDialog() async {
    String animalType = "Poultry";
    String animalName = "";

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Animal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: animalType,
              items: ["Poultry", "Non-Poultry"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
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
            onPressed: () {
              _addAnimal(animalType, animalName);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addAnimal(String type, String name) async {
    if (name.isNotEmpty) {
      await animalsCollection.add({
        'type': type,
        'name': name,
      });
    }
  }

  Future<void> _showEditAnimalDialog(String docId, String currentType, String currentName) async {
    String animalType = currentType;
    String animalName = currentName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Animal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: animalType,
              items: ["Poultry", "Non-Poultry"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
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
            onPressed: () {
              _editAnimal(docId, animalType, animalName);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _editAnimal(String docId, String type, String name) async {
    if (name.isNotEmpty) {
      await animalsCollection.doc(docId).update({
        'type': type,
        'name': name,
      });
    }
  }

  Future<void> _deleteAnimal(String docId) async {
    await animalsCollection.doc(docId).delete();
  }
}
