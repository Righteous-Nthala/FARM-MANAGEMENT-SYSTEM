import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Specificproduct extends StatefulWidget {
  final String productId;
  final String productName;
  const Specificproduct({Key? key, required this.productId, required this.productName}) : super(key: key);

  @override
  _SpecificproductState createState() => _SpecificproductState();
}

class _SpecificproductState extends State<Specificproduct> {
  final CollectionReference detailsCollection =
  FirebaseFirestore.instance.collection('product_details');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productName,  // Display clicked product name here
          style: const TextStyle(
            fontSize: 30, // Font size as requested
            fontWeight: FontWeight.bold, // Bold text style
            color: Colors.black, // Black color for title
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: detailsCollection
            .where('productId', isEqualTo: widget.productId)
            .orderBy('date')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Centering the "No details found" message and the "Add Record" button
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No details records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddDetailsDialog,
                    child: const Text("Add Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView( // Horizontal scrolling for DataTable
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Center(child: Text('Date'))),
                  DataColumn(label: Center(child: Text('Total Amount'))),
                  DataColumn(label: Center(child: Text('High Quality'))),
                  DataColumn(label: Center(child: Text('Low Quality'))),
                  DataColumn(label: Center(child: Text('Damages'))),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                rows: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String date = data['date'];
                  final String totalAmount = data['totalAmount'].toString();
                  final String highQuality = data['highQuality'].toString();
                  final String lowQuality = data['lowQuality'].toString();
                  final String damages = data['damages'].toString();

                  return DataRow(
                    color: MaterialStateProperty.all(Colors.grey[200]), // Gray background for rows
                    cells: [
                      DataCell(Center(child: Text(date))),
                      DataCell(Center(child: Text(totalAmount))),
                      DataCell(Center(child: Text(highQuality))),
                      DataCell(Center(child: Text(lowQuality))),
                      DataCell(Center(child: Text(damages))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),  // Edit icon color set to black
                              onPressed: () => _showEditDetailsDialog(doc.id, date, totalAmount, highQuality, lowQuality, damages),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),  // Delete icon color set to black
                              onPressed: () => _deleteDetailsRecord(doc.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDetailsDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDetailsDialog() async {
    String date = '';
    String totalAmount = '';
    String highQuality = '';
    String lowQuality = '';
    String damages = '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Record"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => date = value,
                  decoration: const InputDecoration(labelText: "Date"),
                ),
                TextField(
                  onChanged: (value) => totalAmount = value,
                  decoration: const InputDecoration(labelText: "Total Amount"),
                ),
                TextField(
                  onChanged: (value) => highQuality = value,
                  decoration: const InputDecoration(labelText: "High Quality"),
                ),
                TextField(
                  onChanged: (value) => lowQuality = value,
                  decoration: const InputDecoration(labelText: "Low Quality"),
                ),
                TextField(
                  onChanged: (value) => damages = value,
                  decoration: const InputDecoration(labelText: "Damages"),
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
                  Navigator.pop(context);
                  if (date.isNotEmpty) {
                    final recordExists = await _checkRecordExists(date);
                    if (recordExists) {
                      _showRecordExistsMessage();
                    } else {
                      await _addDetailsRecord(date, totalAmount, highQuality, lowQuality, damages);
                    }
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

  Future<bool> _checkRecordExists(String date) async {
    final querySnapshot = await detailsCollection
        .where('productId', isEqualTo: widget.productId)
        .where('date', isEqualTo: date)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _addDetailsRecord(String date, String totalAmount, String highQuality, String lowQuality, String damages) async {
    await detailsCollection.add({
      'productId': widget.productId,
      'date': date,
      'totalAmount': totalAmount,
      'highQuality': highQuality,
      'lowQuality': lowQuality,
      'damages': damages,
    });
  }

  void _showRecordExistsMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: const Text('Record already exists for this date'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDetailsDialog(String docId, String date, String totalAmount, String highQuality, String lowQuality, String damages) async {
    String newDate = date;
    String newTotalAmount = totalAmount;
    String newHighQuality = highQuality;
    String newLowQuality = lowQuality;
    String newDamages = damages;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Record"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: newDate),
                  onChanged: (value) => newDate = value,
                  decoration: const InputDecoration(labelText: "Date"),
                ),
                TextField(
                  controller: TextEditingController(text: newTotalAmount),
                  onChanged: (value) => newTotalAmount = value,
                  decoration: const InputDecoration(labelText: "Total Amount"),
                ),
                TextField(
                  controller: TextEditingController(text: newHighQuality),
                  onChanged: (value) => newHighQuality = value,
                  decoration: const InputDecoration(labelText: "High Quality"),
                ),
                TextField(
                  controller: TextEditingController(text: newLowQuality),
                  onChanged: (value) => newLowQuality = value,
                  decoration: const InputDecoration(labelText: "Low Quality"),
                ),
                TextField(
                  controller: TextEditingController(text: newDamages),
                  onChanged: (value) => newDamages = value,
                  decoration: const InputDecoration(labelText: "Damages"),
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
                  Navigator.pop(context);
                  await _updateDetailsRecord(docId, newDate, newTotalAmount, newHighQuality, newLowQuality, newDamages);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateDetailsRecord(String docId, String date, String totalAmount, String highQuality, String lowQuality, String damages) async {
    await detailsCollection.doc(docId).update({
      'date': date,
      'totalAmount': totalAmount,
      'highQuality': highQuality,
      'lowQuality': lowQuality,
      'damages': damages,
    });
  }

  Future<void> _deleteDetailsRecord(String docId) async {
    await detailsCollection.doc(docId).delete();
  }
}
