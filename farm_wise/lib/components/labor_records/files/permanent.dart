import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class PermanentRecordsPage extends StatefulWidget {
  const PermanentRecordsPage({Key? key}) : super(key: key);

  @override
  _PermanentRecordsPageState createState() => _PermanentRecordsPageState();
}

class _PermanentRecordsPageState extends State<PermanentRecordsPage> {
  final CollectionReference permanentRecordsCollection =
  FirebaseFirestore.instance.collection('permanent_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Permanent Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: permanentRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddRecordDialog,
                    child: const Text("Add Record"),
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
                    DataColumn(label: Center(child: Text("Name"))),
                    DataColumn(label: Center(child: Text("Age"))),
                    DataColumn(label: Center(child: Text("Gender"))),
                    DataColumn(label: Center(child: Text("Salary (MWK)"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String name = data['name'];
                    final String age = data['age'].toString();
                    final String gender = data['gender'];
                    final String salary = data['salary'].toString();

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[350]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(name))),
                        DataCell(Center(child: Text(age))),
                        DataCell(Center(child: Text(gender))),
                        DataCell(Center(child: Text(salary))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                name: name,
                                age: age,
                                gender: gender,
                                salary: salary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteRecord(doc.id),
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
        onPressed: _showAddRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddRecordDialog({
    String action = 'Add',
    String? docId,
    String name = '',
    String age = '',
    String gender = '',
    String salary = '',
  }) async {
    final _nameController = TextEditingController(text: name);
    final _ageController = TextEditingController(text: age);
    final _genderController = TextEditingController(text: gender);
    final _salaryController = TextEditingController(text: salary);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: "Salary (MWK)"),
                keyboardType: TextInputType.number,
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
              String name = _nameController.text.trim();
              String age = _ageController.text.trim();
              String gender = _genderController.text.trim();
              String salary = _salaryController.text.trim();

              if (name.isEmpty || age.isEmpty || gender.isEmpty || salary.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate record before adding
              final duplicateExists = await _checkForDuplicateRecord(name, age, gender, salary, docId);

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addRecord(name, age, gender, salary);
              } else {
                await _editRecord(docId!, name, age, gender, salary);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecord(String name, String age, String gender, String salary) async {
    await permanentRecordsCollection.add({
      'name': name,
      'age': int.parse(age),
      'gender': gender,
      'salary': int.parse(salary),
    });
  }

  Future<void> _editRecord(String docId, String name, String age, String gender, String salary) async {
    await permanentRecordsCollection.doc(docId).update({
      'name': name,
      'age': int.parse(age),
      'gender': gender,
      'salary': int.parse(salary),
    });
  }

  Future<void> _deleteRecord(String docId) async {
    await permanentRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateRecord(String name, String age, String gender, String salary, String? docId) async {
    final querySnapshot = await permanentRecordsCollection
        .where('name', isEqualTo: name)
        .where('age', isEqualTo: int.parse(age))
        .where('gender', isEqualTo: gender)
        .where('salary', isEqualTo: int.parse(salary))
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
