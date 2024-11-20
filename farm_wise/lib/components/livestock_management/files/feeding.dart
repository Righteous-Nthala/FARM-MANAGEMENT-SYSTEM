import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingRecordsPage extends StatefulWidget {
  const FeedingRecordsPage({Key? key}) : super(key: key);

  @override
  _FeedingRecordsPageState createState() => _FeedingRecordsPageState();
}

class _FeedingRecordsPageState extends State<FeedingRecordsPage> {
  final CollectionReference feedingRecordsCollection =
  FirebaseFirestore.instance.collection('feeding_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feeding Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: feedingRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No feeding records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddFeedingRecordDialog,
                    child: const Text("Add Feeding Record"),
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
                    DataColumn(label: Center(child: Text("Date"))),
                    DataColumn(label: Center(child: Text("Time"))),
                    DataColumn(label: Center(child: Text("Food Type"))),
                    DataColumn(label: Center(child: Text("Amount"))),
                    DataColumn(label: Center(child: Text("Labor"))), // Centered
                    DataColumn(label: Center(child: Text("Animal"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String date = data['date'];
                    final String time = data['time'];
                    final String foodType = data['food_type'];
                    final String amount = data['amount'].toString();
                    final String labor = data['labor'];
                    final String animal = data['animal'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[200]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text(date))),
                        DataCell(Center(child: Text(time))),
                        DataCell(Center(child: Text(foodType))),
                        DataCell(Center(child: Text(amount))),
                        DataCell(Center(child: Text(labor))),  // Centered labor
                        DataCell(Center(child: Text(animal))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddFeedingRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                date: date,
                                time: time,
                                foodType: foodType,
                                amount: amount,
                                labor: labor,
                                animal: animal,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteFeedingRecord(doc.id),
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
        onPressed: _showAddFeedingRecordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddFeedingRecordDialog({
    String action = 'Add',
    String? docId,
    String date = '',
    String time = '',
    String foodType = '',
    String amount = '',
    String labor = '',
    String animal = '',
  }) async {
    final _dateController = TextEditingController(text: date);
    final _timeController = TextEditingController(text: time);
    final _foodTypeController = TextEditingController(text: foodType);
    final _amountController = TextEditingController(text: amount);
    final _laborController = TextEditingController(text: labor);
    final _animalController = TextEditingController(text: animal);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Feeding Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: "Time"),
              ),
              TextField(
                controller: _foodTypeController,
                decoration: const InputDecoration(labelText: "Food Type"),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              TextField(
                controller: _laborController,
                decoration: const InputDecoration(labelText: "Labor"),
              ),
              TextField(
                controller: _animalController,
                decoration: const InputDecoration(labelText: "Animal"),
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
              String date = _dateController.text.trim();
              String time = _timeController.text.trim();
              String foodType = _foodTypeController.text.trim();
              String amount = _amountController.text.trim();
              String labor = _laborController.text.trim();
              String animal = _animalController.text.trim();

              if (date.isEmpty || time.isEmpty || foodType.isEmpty ||
                  amount.isEmpty || labor.isEmpty || animal.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate row before adding
              final duplicateExists = await _checkForDuplicateFeedingRecord(
                  date, time, foodType, amount, labor, animal, docId
              );

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addFeedingRecord(date, time, foodType, amount, labor, animal);
              } else {
                await _editFeedingRecord(
                    docId!, date, time, foodType, amount, labor, animal);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addFeedingRecord(String date, String time, String foodType,
      String amount, String labor, String animal) async {
    await feedingRecordsCollection.add({
      'date': date,
      'time': time,
      'food_type': foodType,
      'amount': amount,
      'labor': labor,
      'animal': animal,
    });
  }

  Future<void> _editFeedingRecord(String docId, String date, String time,
      String foodType, String amount, String labor, String animal) async {
    await feedingRecordsCollection.doc(docId).update({
      'date': date,
      'time': time,
      'food_type': foodType,
      'amount': amount,
      'labor': labor,
      'animal': animal,
    });
  }

  Future<void> _deleteFeedingRecord(String docId) async {
    await feedingRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateFeedingRecord(
      String date, String time, String foodType, String amount,
      String labor, String animal, String? docId) async {
    final querySnapshot = await feedingRecordsCollection
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('food_type', isEqualTo: foodType)
        .where('amount', isEqualTo: amount)
        .where('labor', isEqualTo: labor)
        .where('animal', isEqualTo: animal)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
