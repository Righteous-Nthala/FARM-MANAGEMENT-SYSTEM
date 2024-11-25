import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class TemporaryRecordsPage extends StatefulWidget {
  const TemporaryRecordsPage({super.key});

  @override
  _TemporaryRecordsPageState createState() => _TemporaryRecordsPageState();
}

class _TemporaryRecordsPageState extends State<TemporaryRecordsPage> {
  final CollectionReference temporaryRecordsCollection =
      FirebaseFirestore.instance.collection('temporary_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temporary Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: temporaryRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
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
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 15,
                columns: const [
                  DataColumn(label: Text("No.")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Age")),
                  DataColumn(label: Text("Gender")),
                  DataColumn(label: Text("Assignment")),
                  DataColumn(label: Text("Date Assigned")),
                  DataColumn(label: Text("Due Date")),
                  DataColumn(label: Text("Wage (MWK)")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: snapshot.data!.docs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;

                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(data['name'] ?? "")),
                      DataCell(Text(data['age'].toString())),
                      DataCell(Text(data['gender'] ?? "")),
                      DataCell(Text(data['assignment'] ?? "")),
                      DataCell(Text(data['date_assigned'] ?? "")),
                      DataCell(Text(data['due_date'] ?? "")),
                      DataCell(Text(data['wage'].toString())),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddRecordDialog(
                              action: 'Edit',
                              docId: doc.id,
                              name: data['name'],
                              age: data['age'].toString(),
                              gender: data['gender'],
                              assignment: data['assignment'],
                              dateAssigned: data['date_assigned'],
                              dueDate: data['due_date'],
                              wage: data['wage'].toString(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRecord(doc.id),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
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
    String assignment = '',
    String dateAssigned = '',
    String dueDate = '',
    String wage = '',
  }) async {
    final nameController = TextEditingController(text: name);
    final ageController = TextEditingController(text: age);
    final genderController = TextEditingController(text: gender);
    final assignmentController = TextEditingController(text: assignment);
    final dateAssignedController = TextEditingController(text: dateAssigned);
    final dueDateController = TextEditingController(text: dueDate);
    final wageController = TextEditingController(text: wage);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Record"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
              TextField(controller: genderController, decoration: const InputDecoration(labelText: "Gender")),
              TextField(controller: assignmentController, decoration: const InputDecoration(labelText: "Assignment")),
              TextField(controller: dateAssignedController, decoration: const InputDecoration(labelText: "Date Assigned")),
              TextField(controller: dueDateController, decoration: const InputDecoration(labelText: "Due Date")),
              TextField(controller: wageController, decoration: const InputDecoration(labelText: "Wage"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final record = {
                'name': nameController.text.trim(),
                'age': int.parse(ageController.text.trim()),
                'gender': genderController.text.trim(),
                'assignment': assignmentController.text.trim(),
                'date_assigned': dateAssignedController.text.trim(),
                'due_date': dueDateController.text.trim(),
                'wage': int.parse(wageController.text.trim()),
              };

              if (action == 'Add') {
                await _addRecord(record);
              } else {
                await _editRecord(docId!, record);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecord(Map<String, dynamic> record) async {
    try {
      await temporaryRecordsCollection.add(record);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding record: $e")));
    }
  }

  Future<void> _editRecord(String docId, Map<String, dynamic> record) async {
    try {
      await temporaryRecordsCollection.doc(docId).update(record);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating record: $e")));
    }
  }

  Future<void> _deleteRecord(String docId) async {
    try {
      await temporaryRecordsCollection.doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting record: $e")));
    }
  }
}
