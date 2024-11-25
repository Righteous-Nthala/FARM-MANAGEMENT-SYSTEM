import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class SalesRecordsPage extends StatefulWidget {
  const SalesRecordsPage({Key? key}) : super(key: key);

  @override
  _SalesRecordsPageState createState() => _SalesRecordsPageState();
}

class _SalesRecordsPageState extends State<SalesRecordsPage> {
  final CollectionReference salesRecordsCollection =
  FirebaseFirestore.instance.collection('sales_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: salesRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No sales records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddSalesRecordDialog,
                    child: const Text("Add Sales Record"),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView( // Make the table scrollable vertically
              child: SingleChildScrollView( // Allow horizontal scrolling
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,  // Slight increase in column spacing
                  columns: const [
                    DataColumn(label: Center(child: Text("No."))),
                    DataColumn(label: Center(child: Text("Sales ID"))),
                    DataColumn(label: Center(child: Text("Crop ID"))),
                    DataColumn(label: Center(child: Text("Crop Name"))),
                    DataColumn(label: Center(child: Text("Sales Date"))),
                    DataColumn(label: Center(child: Text("Buyer Name"))),
                    DataColumn(label: Center(child: Text("Buyer Contact"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String salesId = data['sales_id'];
                    final String cropId = data['crop_id'];
                    final String cropName = data['crop_name'];
                    final String salesDate = data['sales_date'];
                    final String buyerName = data['buyer_name'];
                    final String buyerContact = data['buyer_contact'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[350]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(salesId))),
                        DataCell(Center(child: Text(cropId))),
                        DataCell(Center(child: Text(cropName))),
                        DataCell(Center(child: Text(salesDate))),
                        DataCell(Center(child: Text(buyerName))),
                        DataCell(Center(child: Text(buyerContact))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddSalesRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                salesId: salesId,
                                cropId: cropId,
                                cropName: cropName,
                                salesDate: salesDate,
                                buyerName: buyerName,
                                buyerContact: buyerContact,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteSalesRecord(doc.id),
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
        onPressed: _showAddSalesRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddSalesRecordDialog({
    String action = 'Add',
    String? docId,
    String salesId = '',
    String cropId = '',
    String cropName = '',
    String salesDate = '',
    String buyerName = '',
    String buyerContact = '',
  }) async {
    final _salesIdController = TextEditingController(text: salesId);
    final _cropIdController = TextEditingController(text: cropId);
    final _cropNameController = TextEditingController(text: cropName);
    final _salesDateController = TextEditingController(text: salesDate);
    final _buyerNameController = TextEditingController(text: buyerName);
    final _buyerContactController = TextEditingController(text: buyerContact);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Sales Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _salesIdController,
                decoration: const InputDecoration(labelText: "Sales ID"),
              ),
              TextField(
                controller: _cropIdController,
                decoration: const InputDecoration(labelText: "Crop ID"),
              ),
              TextField(
                controller: _cropNameController,
                decoration: const InputDecoration(labelText: "Crop Name"),
              ),
              TextField(
                controller: _salesDateController,
                decoration: const InputDecoration(labelText: "Sales Date"),
              ),
              TextField(
                controller: _buyerNameController,
                decoration: const InputDecoration(labelText: "Buyer Name"),
              ),
              TextField(
                controller: _buyerContactController,
                decoration: const InputDecoration(labelText: "Buyer Contact"),
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
              String salesId = _salesIdController.text.trim();
              String cropId = _cropIdController.text.trim();
              String cropName = _cropNameController.text.trim();
              String salesDate = _salesDateController.text.trim();
              String buyerName = _buyerNameController.text.trim();
              String buyerContact = _buyerContactController.text.trim();

              if (salesId.isEmpty || cropId.isEmpty || cropName.isEmpty ||
                  salesDate.isEmpty || buyerName.isEmpty || buyerContact.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate row before adding
              final duplicateExists = await _checkForDuplicateSalesRecord(
                  salesId, cropId, cropName, salesDate, buyerName, buyerContact, docId
              );

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addSalesRecord(salesId, cropId, cropName, salesDate, buyerName, buyerContact);
              } else {
                await _editSalesRecord(
                    docId!, salesId, cropId, cropName, salesDate, buyerName, buyerContact);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addSalesRecord(String salesId, String cropId, String cropName,
      String salesDate, String buyerName, String buyerContact) async {
    await salesRecordsCollection.add({
      'sales_id': salesId,
      'crop_id': cropId,
      'crop_name': cropName,
      'sales_date': salesDate,
      'buyer_name': buyerName,
      'buyer_contact': buyerContact,
    });
  }

  Future<void> _editSalesRecord(String docId, String salesId, String cropId,
      String cropName, String salesDate, String buyerName, String buyerContact) async {
    await salesRecordsCollection.doc(docId).update({
      'sales_id': salesId,
      'crop_id': cropId,
      'crop_name': cropName,
      'sales_date': salesDate,
      'buyer_name': buyerName,
      'buyer_contact': buyerContact,
    });
  }

  Future<void> _deleteSalesRecord(String docId) async {
    await salesRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateSalesRecord(
      String salesId, String cropId, String cropName, String salesDate,
      String buyerName, String buyerContact, String? docId) async {
    final querySnapshot = await salesRecordsCollection
        .where('sales_id', isEqualTo: salesId)
        .where('crop_id', isEqualTo: cropId)
        .where('crop_name', isEqualTo: cropName)
        .where('sales_date', isEqualTo: salesDate)
        .where('buyer_name', isEqualTo: buyerName)
        .where('buyer_contact', isEqualTo: buyerContact)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
