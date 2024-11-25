import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

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
          widget.productName,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
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
            final documents = snapshot.data!.docs;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Center(child: Text('No'))),
                  DataColumn(label: Center(child: Text('Date'))),
                  DataColumn(label: Center(child: Text('Total Amount'))),
                  DataColumn(label: Center(child: Text('High Quality'))),
                  DataColumn(label: Center(child: Text('Low Quality'))),
                  DataColumn(label: Center(child: Text('Damages'))),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                rows: List.generate(documents.length, (index) {
                  final doc = documents[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String date = data['date'];
                  final String totalAmount = data['totalAmount'].toString();
                  final String highQuality = data['highQuality'].toString();
                  final String lowQuality = data['lowQuality'].toString();
                  final String damages = data['damages'].toString();

                  return DataRow(
                    color: MaterialStateProperty.all(Colors.grey[350]),
                    cells: [
                      DataCell(Center(child: Text((index + 1).toString()))),
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
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showEditDetailsDialog(
                                doc.id,
                                date,
                                totalAmount,
                                highQuality,
                                lowQuality,
                                damages,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteDetailsRecord(doc.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDetailsDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
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
                onPressed: () {
                  Navigator.pop(context);
                  if (date.isEmpty ||
                      totalAmount.isEmpty ||
                      highQuality.isEmpty ||
                      lowQuality.isEmpty ||
                      damages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill in all fields")),
                    );
                  } else {
                    _addDetailsRecord(date, totalAmount, highQuality, lowQuality, damages);
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

  Future<void> _addDetailsRecord(
      String date,
      String totalAmount,
      String highQuality,
      String lowQuality,
      String damages,
      ) async {
    await detailsCollection.add({
      'productId': widget.productId,
      'date': date,
      'totalAmount': totalAmount,
      'highQuality': highQuality,
      'lowQuality': lowQuality,
      'damages': damages,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Record added successfully")),
    );
  }

  Future<void> _showEditDetailsDialog(
      String docId,
      String date,
      String totalAmount,
      String highQuality,
      String lowQuality,
      String damages,
      ) async {
    String newDate = date;
    String newTotalAmount = totalAmount;
    String newHighQuality = highQuality;
    String newLowQuality = lowQuality;
    String newDamages = damages;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  Future<void> _updateDetailsRecord(
      String docId,
      String date,
      String totalAmount,
      String highQuality,
      String lowQuality,
      String damages,
      ) async {
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
