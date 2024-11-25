import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class CropRecordsPage extends StatefulWidget {
  const CropRecordsPage({Key? key}) : super(key: key);

  @override
  _CropRecordsPageState createState() => _CropRecordsPageState();
}

class _CropRecordsPageState extends State<CropRecordsPage> {
  final CollectionReference cropRecordsCollection =
  FirebaseFirestore.instance.collection('crop_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Records',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: cropRecordsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No crop records found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddCropRecordDialog,
                    child: const Text("Add Crop Record"),
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
                    DataColumn(label: Center(child: Text("ID"))),
                    DataColumn(label: Center(child: Text("Name"))),
                    DataColumn(label: Center(child: Text("Variety"))),
                    DataColumn(label: Center(child: Text("Amount of Seeds (kg)"))),
                    DataColumn(label: Center(child: Text("Date Planted"))),
                    DataColumn(label: Center(child: Text("Plot No."))),
                    DataColumn(label: Center(child: Text("Estimated Harvest Quantity (kg)"))),
                    DataColumn(label: Center(child: Text("Quantity Harvested (kg)"))),
                    DataColumn(label: Center(child: Text("Date Harvested"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String id = data['id'];
                    final String name = data['name'];
                    final String variety = data['variety'];
                    final String amount = data['amount_of_seeds'].toString();
                    final String datePlanted = data['date_planted'];
                    final String plotNo = data['plot_no'];
                    final String estimatedHarvest = data['estimated_harvest'].toString();
                    final String quantityHarvested = data['quantity_harvested'].toString();
                    final String dateHarvested = data['date_harvested'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey[350]!),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))), // Row number
                        DataCell(Center(child: Text(id))),
                        DataCell(Center(child: Text(name))),
                        DataCell(Center(child: Text(variety))),
                        DataCell(Center(child: Text(amount))),
                        DataCell(Center(child: Text(datePlanted))),
                        DataCell(Center(child: Text(plotNo))),
                        DataCell(Center(child: Text(estimatedHarvest))),
                        DataCell(Center(child: Text(quantityHarvested))),
                        DataCell(Center(child: Text(dateHarvested))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddCropRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                id: id,
                                name: name,
                                variety: variety,
                                amount: amount,
                                datePlanted: datePlanted,
                                plotNo: plotNo,
                                estimatedHarvest: estimatedHarvest,
                                quantityHarvested: quantityHarvested,
                                dateHarvested: dateHarvested,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteCropRecord(doc.id),
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
        onPressed: _showAddCropRecordDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddCropRecordDialog({
    String action = 'Add',
    String? docId,
    String id = '',
    String name = '',
    String variety = '',
    String amount = '',
    String datePlanted = '',
    String plotNo = '',
    String estimatedHarvest = '',
    String quantityHarvested = '',
    String dateHarvested = '',
  }) async {
    final _idController = TextEditingController(text: id);
    final _nameController = TextEditingController(text: name);
    final _varietyController = TextEditingController(text: variety);
    final _amountController = TextEditingController(text: amount);
    final _datePlantedController = TextEditingController(text: datePlanted);
    final _plotNoController = TextEditingController(text: plotNo);
    final _estimatedHarvestController = TextEditingController(text: estimatedHarvest);
    final _quantityHarvestedController = TextEditingController(text: quantityHarvested);
    final _dateHarvestedController = TextEditingController(text: dateHarvested);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Crop Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: "ID"),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _varietyController,
                decoration: const InputDecoration(labelText: "Variety"),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount of Seeds (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _datePlantedController,
                decoration: const InputDecoration(labelText: "Date Planted"),
              ),
              TextField(
                controller: _plotNoController,
                decoration: const InputDecoration(labelText: "Plot No."),
              ),
              TextField(
                controller: _estimatedHarvestController,
                decoration: const InputDecoration(labelText: "Estimated Harvest Quantity (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _quantityHarvestedController,
                decoration: const InputDecoration(labelText: "Quantity Harvested (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dateHarvestedController,
                decoration: const InputDecoration(labelText: "Date Harvested"),
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
              String id = _idController.text.trim();
              String name = _nameController.text.trim();
              String variety = _varietyController.text.trim();
              String amount = _amountController.text.trim();
              String datePlanted = _datePlantedController.text.trim();
              String plotNo = _plotNoController.text.trim();
              String estimatedHarvest = _estimatedHarvestController.text.trim();
              String quantityHarvested = _quantityHarvestedController.text.trim();
              String dateHarvested = _dateHarvestedController.text.trim();

              if (id.isEmpty || name.isEmpty || variety.isEmpty ||
                  amount.isEmpty || datePlanted.isEmpty || plotNo.isEmpty ||
                  estimatedHarvest.isEmpty || quantityHarvested.isEmpty || dateHarvested.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              // Check for duplicate row before adding
              final duplicateExists = await _checkForDuplicateCropRecord(
                  id, name, variety, amount, datePlanted, plotNo, estimatedHarvest,
                  quantityHarvested, dateHarvested, docId);

              if (duplicateExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This record already exists")),
                );
                return;
              }

              if (action == 'Add') {
                await _addCropRecord(id, name, variety, amount, datePlanted, plotNo,
                    estimatedHarvest, quantityHarvested, dateHarvested);
              } else {
                await _editCropRecord(docId!, id, name, variety, amount, datePlanted, plotNo,
                    estimatedHarvest, quantityHarvested, dateHarvested);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addCropRecord(String id, String name, String variety, String amount,
      String datePlanted, String plotNo, String estimatedHarvest, String quantityHarvested,
      String dateHarvested) async {
    await cropRecordsCollection.add({
      'id': id,
      'name': name,
      'variety': variety,
      'amount_of_seeds': amount,
      'date_planted': datePlanted,
      'plot_no': plotNo,
      'estimated_harvest': estimatedHarvest,
      'quantity_harvested': quantityHarvested,
      'date_harvested': dateHarvested,
    });
  }

  Future<void> _editCropRecord(String docId, String id, String name, String variety,
      String amount, String datePlanted, String plotNo, String estimatedHarvest,
      String quantityHarvested, String dateHarvested) async {
    await cropRecordsCollection.doc(docId).update({
      'id': id,
      'name': name,
      'variety': variety,
      'amount_of_seeds': amount,
      'date_planted': datePlanted,
      'plot_no': plotNo,
      'estimated_harvest': estimatedHarvest,
      'quantity_harvested': quantityHarvested,
      'date_harvested': dateHarvested,
    });
  }

  Future<void> _deleteCropRecord(String docId) async {
    await cropRecordsCollection.doc(docId).delete();
  }

  Future<bool> _checkForDuplicateCropRecord(
      String id, String name, String variety, String amount, String datePlanted,
      String plotNo, String estimatedHarvest, String quantityHarvested,
      String dateHarvested, String? docId) async {
    final querySnapshot = await cropRecordsCollection
        .where('id', isEqualTo: id)
        .where('name', isEqualTo: name)
        .where('variety', isEqualTo: variety)
        .where('amount_of_seeds', isEqualTo: amount)
        .where('date_planted', isEqualTo: datePlanted)
        .where('plot_no', isEqualTo: plotNo)
        .where('estimated_harvest', isEqualTo: estimatedHarvest)
        .where('quantity_harvested', isEqualTo: quantityHarvested)
        .where('date_harvested', isEqualTo: dateHarvested)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id != docId) {
        return true;  // Duplicate found
      }
    }

    return false;  // No duplicates
  }
}
