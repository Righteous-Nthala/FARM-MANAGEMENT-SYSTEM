import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class ExpenditureRecordsPage extends StatefulWidget {
  const ExpenditureRecordsPage({Key? key}) : super(key: key);

  @override
  _ExpenditureRecordsPageState createState() => _ExpenditureRecordsPageState();
}

class _ExpenditureRecordsPageState extends State<ExpenditureRecordsPage> {
  final CollectionReference expenditureRecordsCollection =
  FirebaseFirestore.instance.collection('expenditure_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenditure Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: expenditureRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No expenditure records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddExpenditureRecordDialog,
                    child: const Text("Add Expenditure Record"),
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
                    DataColumn(label: Center(child: Text("Expenditure Type"))),
                    DataColumn(label: Center(child: Text("Amount (MWK)"))),
                    DataColumn(label: Center(child: Text("Date"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String expenditureType = data['expenditure_type'];
                    final String amount = data['amount'].toString();
                    final String date = data['date'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[350]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(expenditureType))),
                        DataCell(Center(child: Text(amount))),
                        DataCell(Center(child: Text(date))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddExpenditureRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                expenditureType: expenditureType,
                                amount: amount,
                                date: date,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteExpenditureRecord(doc.id),
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
        onPressed: _showAddExpenditureRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddExpenditureRecordDialog({
    String action = 'Add',
    String? docId,
    String expenditureType = '',
    String amount = '',
    String date = '',
  }) async {
    final _expenditureTypeController = TextEditingController(text: expenditureType);
    final _amountController = TextEditingController(text: amount);
    final _dateController = TextEditingController(text: date);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Expenditure Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _expenditureTypeController,
                decoration: const InputDecoration(labelText: "Expenditure Type"),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount (MWK)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
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
              String expenditureType = _expenditureTypeController.text.trim();
              String amount = _amountController.text.trim();
              String date = _dateController.text.trim();

              if (expenditureType.isEmpty || amount.isEmpty || date.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate record before adding
              final duplicateExists = await _checkForDuplicateExpenditureRecord(
                  expenditureType, amount, date, docId);

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addExpenditureRecord(expenditureType, amount, date);
              } else {
                await _editExpenditureRecord(docId!, expenditureType, amount, date);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addExpenditureRecord(
      String expenditureType, String amount, String date) async {
    await expenditureRecordsCollection.add({
      'expenditure_type': expenditureType,
      'amount': int.parse(amount),
      'date': date,
    });
  }

  Future<void> _editExpenditureRecord(
      String docId, String expenditureType, String amount, String date) async {
    await expenditureRecordsCollection.doc(docId).update({
      'expenditure_type': expenditureType,
      'amount': int.parse(amount),
      'date': date,
    });
  }

  Future<void> _deleteExpenditureRecord(String docId) async {
    await expenditureRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateExpenditureRecord(
      String expenditureType, String amount, String date, String? docId) async {
    final querySnapshot = await expenditureRecordsCollection
        .where('expenditure_type', isEqualTo: expenditureType)
        .where('amount', isEqualTo: int.parse(amount))
        .where('date', isEqualTo: date)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
