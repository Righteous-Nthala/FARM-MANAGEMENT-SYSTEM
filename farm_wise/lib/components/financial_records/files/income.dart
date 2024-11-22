import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class IncomeRecordsPage extends StatefulWidget {
  const IncomeRecordsPage({Key? key}) : super(key: key);

  @override
  _IncomeRecordsPageState createState() => _IncomeRecordsPageState();
}

class _IncomeRecordsPageState extends State<IncomeRecordsPage> {
  final CollectionReference incomeRecordsCollection =
  FirebaseFirestore.instance.collection('income_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Income Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: incomeRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No income records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddIncomeRecordDialog,
                    child: const Text("Add Income Record"),
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
                    DataColumn(label: Center(child: Text("Source"))),
                    DataColumn(label: Center(child: Text("Amount (MWK)"))),
                    DataColumn(label: Center(child: Text("Date"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String source = data['source'];
                    final String amount = data['amount'].toString();
                    final String date = data['date'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[350]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(source))),
                        DataCell(Center(child: Text(amount))),
                        DataCell(Center(child: Text(date))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddIncomeRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                source: source,
                                amount: amount,
                                date: date,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteIncomeRecord(doc.id),
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
        onPressed: _showAddIncomeRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddIncomeRecordDialog({
    String action = 'Add',
    String? docId,
    String source = '',
    String amount = '',
    String date = '',
  }) async {
    final _sourceController = TextEditingController(text: source);
    final _amountController = TextEditingController(text: amount);
    final _dateController = TextEditingController(text: date);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Income Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: "Source"),
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
              String source = _sourceController.text.trim();
              String amount = _amountController.text.trim();
              String date = _dateController.text.trim();

              if (source.isEmpty || amount.isEmpty || date.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate record before adding
              final duplicateExists = await _checkForDuplicateIncomeRecord(
                  source, amount, date, docId);

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addIncomeRecord(source, amount, date);
              } else {
                await _editIncomeRecord(docId!, source, amount, date);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addIncomeRecord(String source, String amount, String date) async {
    await incomeRecordsCollection.add({
      'source': source,
      'amount': int.parse(amount),
      'date': date,
    });
  }

  Future<void> _editIncomeRecord(
      String docId, String source, String amount, String date) async {
    await incomeRecordsCollection.doc(docId).update({
      'source': source,
      'amount': int.parse(amount),
      'date': date,
    });
  }

  Future<void> _deleteIncomeRecord(String docId) async {
    await incomeRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateIncomeRecord(
      String source, String amount, String date, String? docId) async {
    final querySnapshot = await incomeRecordsCollection
        .where('source', isEqualTo: source)
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
