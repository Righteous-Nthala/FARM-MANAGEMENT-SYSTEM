import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Center(child: Text("No"))),  // Row number column
                    DataColumn(label: Center(child: Text("Animal/Product"))),
                    DataColumn(label: Center(child: Text("Quantity"))),
                    DataColumn(label: Center(child: Text("Total Income (Mkw)"))),
                    DataColumn(label: Center(child: Text("Customer"))),
                    DataColumn(label: Center(child: Text("Date"))),
                    DataColumn(label: Center(child: Text("Actions"))),
                  ],
                  rows: List.generate(snapshot.data!.docs.length, (index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String animalProduct = data['animal_product'];
                    final int quantity = data['quantity'];
                    final double totalIncome = data['total_income'];
                    final String customer = data['customer'];
                    final String date = data['date'];

                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[200]!,
                      ),
                      cells: [
                        DataCell(Center(child: Text('${index + 1}'))),  // Row number
                        DataCell(Center(child: Text(animalProduct))),
                        DataCell(Center(child: Text(quantity.toString()))),
                        DataCell(Center(child: Text(totalIncome.toStringAsFixed(2)))),
                        DataCell(Center(child: Text(customer))),
                        DataCell(Center(child: Text(date))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showAddSalesRecordDialog(
                                action: 'Edit',
                                docId: doc.id,
                                animalProduct: animalProduct,
                                quantity: quantity.toString(),
                                totalIncome: totalIncome.toString(),
                                customer: customer,
                                date: date,
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
    );
  }

  Future<void> _showAddSalesRecordDialog({
    String action = 'Add',
    String? docId,
    String animalProduct = '',
    String quantity = '',
    String totalIncome = '',
    String customer = '',
    String date = '',
  }) async {
    final _animalProductController = TextEditingController(text: animalProduct);
    final _quantityController = TextEditingController(text: quantity);
    final _totalIncomeController = TextEditingController(text: totalIncome);
    final _customerController = TextEditingController(text: customer);
    final _dateController = TextEditingController(text: date);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Sales Record"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _animalProductController,
                decoration: const InputDecoration(labelText: "Animal/Product"),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _totalIncomeController,
                decoration: const InputDecoration(labelText: "Total Income (Mkw)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _customerController,
                decoration: const InputDecoration(labelText: "Customer"),
                textCapitalization: TextCapitalization.words,
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
              String animalProduct = _capitalizeFirstLetter(_animalProductController.text.trim());
              int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
              double totalIncome = double.tryParse(_totalIncomeController.text.trim()) ?? 0.0;
              String customer = _capitalizeFirstLetter(_customerController.text.trim());
              String date = _dateController.text.trim();

              if (action == 'Add') {
                await _addSalesRecord(animalProduct, quantity, totalIncome, customer, date);
              } else {
                await _editSalesRecord(docId!, animalProduct, quantity, totalIncome, customer, date);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  Future<void> _addSalesRecord(
      String animalProduct,
      int quantity,
      double totalIncome,
      String customer,
      String date,
      ) async {
    await salesRecordsCollection.add({
      'animal_product': animalProduct,
      'quantity': quantity,
      'total_income': totalIncome,
      'customer': customer,
      'date': date,
    });
  }

  Future<void> _editSalesRecord(
      String docId,
      String animalProduct,
      int quantity,
      double totalIncome,
      String customer,
      String date,
      ) async {
    await salesRecordsCollection.doc(docId).update({
      'animal_product': animalProduct,
      'quantity': quantity,
      'total_income': totalIncome,
      'customer': customer,
      'date': date,
    });
  }

  Future<void> _deleteSalesRecord(String docId) async {
    await salesRecordsCollection.doc(docId).delete();
  }
}
