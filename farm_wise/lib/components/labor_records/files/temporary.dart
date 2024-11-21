import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class TemporaryRecordsPage extends StatefulWidget {
  const TemporaryRecordsPage({Key? key}) : super(key: key);

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
                    DataColumn(label: Center(child: Text("Assignment"))),
                    DataColumn(label: Center(child: Text("Date Assigned"))),
                    DataColumn(label: Center(child: Text("Due Date"))),
                    DataColumn(label: Center(child: Text("Wage (MWK)"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String name = data['name'];
                    final String age = data['age'].toString();
                    final String gender = data['gender'];
                    final String assignment = data['assignment'];
                    final String dateAssigned = data['date_assigned'];
                    final String dueDate = data['due_date'];
                    final String wage = data['wage'].toString();

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[350]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(name))),
                        DataCell(Center(child: Text(age))),
                        DataCell(Center(child: Text(gender))),
                        DataCell(Center(child: Text(assignment))),
                        DataCell(Center(child: Text(dateAssigned))),
                        DataCell(Center(child: Text(dueDate))),
                        DataCell(Center(child: Text(wage))),
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
                                assignment: assignment,
                                dateAssigned: dateAssigned,
                                dueDate: dueDate,
                                wage: wage,
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
    String assignment = '',
    String dateAssigned = '',
    String dueDate = '',
    String wage = '',
  }) async {
    final _nameController = TextEditingController(text: name);
    final _ageController = TextEditingController(text: age);
    final _genderController = TextEditingController(text: gender);
    final _assignmentController = TextEditingController(text: assignment);
    final _dateAssignedController = TextEditingController(text: dateAssigned);
    final _dueDateController = TextEditingController(text: dueDate);
    final _wageController = TextEditingController(text: wage);

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
                controller: _assignmentController,
                decoration: const InputDecoration(labelText: "Assignment"),
              ),
              TextField(
                controller: _dateAssignedController,
                decoration: const InputDecoration(labelText: "Date Assigned"),
              ),
              TextField(
                controller: _dueDateController,
                decoration: const InputDecoration(labelText: "Due Date"),
              ),
              TextField(
                controller: _wageController,
                decoration: const InputDecoration(labelText: "Wage (MWK)"),
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
              String assignment = _assignmentController.text.trim();
              String dateAssigned = _dateAssignedController.text.trim();
              String dueDate = _dueDateController.text.trim();
              String wage = _wageController.text.trim();

              if (name.isEmpty || age.isEmpty || gender.isEmpty || assignment.isEmpty ||
                  dateAssigned.isEmpty || dueDate.isEmpty || wage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate record before adding
              final duplicateExists = await _checkForDuplicateRecord(
                  name, age, gender, assignment, dateAssigned, dueDate, wage, docId
              );

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addRecord(name, age, gender, assignment, dateAssigned, dueDate, wage);
              } else {
                await _editRecord(docId!, name, age, gender, assignment, dateAssigned, dueDate, wage);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecord(String name, String age, String gender, String assignment,
      String dateAssigned, String dueDate, String wage) async {
    await temporaryRecordsCollection.add({
      'name': name,
      'age': int.parse(age),
      'gender': gender,
      'assignment': assignment,
      'date_assigned': dateAssigned,
      'due_date': dueDate,
      'wage': int.parse(wage),
    });
  }

  Future<void> _editRecord(String docId, String name, String age, String gender, String assignment,
      String dateAssigned, String dueDate, String wage) async {
    await temporaryRecordsCollection.doc(docId).update({
      'name': name,
      'age': int.parse(age),
      'gender': gender,
      'assignment': assignment,
      'date_assigned': dateAssigned,
      'due_date': dueDate,
      'wage': int.parse(wage),
    });
  }

  Future<void> _deleteRecord(String docId) async {
    await temporaryRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateRecord(
      String name, String age, String gender, String assignment,
      String dateAssigned, String dueDate, String wage, String? docId) async {
    final querySnapshot = await temporaryRecordsCollection
        .where('name', isEqualTo: name)
        .where('age', isEqualTo: int.parse(age))
        .where('gender', isEqualTo: gender)
        .where('assignment', isEqualTo: assignment)
        .where('date_assigned', isEqualTo: dateAssigned)
        .where('due_date', isEqualTo: dueDate)
        .where('wage', isEqualTo: int.parse(wage))
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
