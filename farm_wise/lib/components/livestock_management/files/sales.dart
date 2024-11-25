import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class SalesRecordsPage extends StatefulWidget {
  const SalesRecordsPage({Key? key}) : super(key: key);

  @override
  _SalesRecordsPageState createState() => _SalesRecordsPageState();
}

class _SalesRecordsPageState extends State<SalesRecordsPage> {
  final CollectionReference salesCollection =
  FirebaseFirestore.instance.collection('sales_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sales Records",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: salesCollection.orderBy('date').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No sales records found."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddSalesDialog,
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
                  DataColumn(label: Center(child: Text('Animal/Product'))),
                  DataColumn(label: Center(child: Text('Quantity'))),
                  DataColumn(label: Center(child: Text('Income (MWK)'))),
                  DataColumn(label: Center(child: Text('Customer'))),
                  DataColumn(label: Center(child: Text('Date'))),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                rows: List.generate(documents.length, (index) {
                  final doc = documents[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String animalProduct = data['animalProduct'] ?? '';
                  final String quantity = data['quantity'] ?? '';
                  final String income = data['income'] ?? '';
                  final String customer = data['customer'] ?? '';
                  final String date = data['date'] ?? '';

                  return DataRow(
                    color: MaterialStateProperty.all(Colors.grey[350]),
                    cells: [
                      DataCell(Center(child: Text((index + 1).toString()))),
                      DataCell(Center(child: Text(animalProduct))),
                      DataCell(Center(child: Text(quantity))),
                      DataCell(Center(child: Text(income))),
                      DataCell(Center(child: Text(customer))),
                      DataCell(Center(child: Text(date))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () => _showEditSalesDialog(
                                doc.id,
                                animalProduct,
                                quantity,
                                income,
                                customer,
                                date,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () => _deleteSalesRecord(doc.id),
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
        onPressed: _showAddSalesDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  Future<void> _showAddSalesDialog() async {
    String animalProduct = '';
    String quantity = '';
    String income = '';
    String customer = '';
    String date = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Sales Record"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => animalProduct = value,
              decoration: const InputDecoration(labelText: "Animal/Product"),
            ),
            TextField(
              onChanged: (value) => quantity = value,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              onChanged: (value) => income = value,
              decoration: const InputDecoration(labelText: "Income (MWK)"),
            ),
            TextField(
              onChanged: (value) => customer = value,
              decoration: const InputDecoration(labelText: "Customer"),
            ),
            TextField(
              onChanged: (value) => date = value,
              decoration: const InputDecoration(labelText: "Date"),
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
              if (animalProduct.isEmpty ||
                  quantity.isEmpty ||
                  income.isEmpty ||
                  customer.isEmpty ||
                  date.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
              } else {
                _addSalesRecord(animalProduct, quantity, income, customer, date);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addSalesRecord(
      String animalProduct,
      String quantity,
      String income,
      String customer,
      String date,
      ) async {
    await salesCollection.add({
      'animalProduct': animalProduct,
      'quantity': quantity,
      'income': income,
      'customer': customer,
      'date': date,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sales record added successfully")),
    );
  }

  Future<void> _showEditSalesDialog(
      String docId,
      String animalProduct,
      String quantity,
      String income,
      String customer,
      String date,
      ) async {
    String newAnimalProduct = animalProduct;
    String newQuantity = quantity;
    String newIncome = income;
    String newCustomer = customer;
    String newDate = date;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Sales Record"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: newAnimalProduct),
              onChanged: (value) => newAnimalProduct = value,
              decoration: const InputDecoration(labelText: "Animal/Product"),
            ),
            TextField(
              controller: TextEditingController(text: newQuantity),
              onChanged: (value) => newQuantity = value,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: TextEditingController(text: newIncome),
              onChanged: (value) => newIncome = value,
              decoration: const InputDecoration(labelText: "Income (MWK)"),
            ),
            TextField(
              controller: TextEditingController(text: newCustomer),
              onChanged: (value) => newCustomer = value,
              decoration: const InputDecoration(labelText: "Customer"),
            ),
            TextField(
              controller: TextEditingController(text: newDate),
              onChanged: (value) => newDate = value,
              decoration: const InputDecoration(labelText: "Date"),
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
              await _updateSalesRecord(docId, newAnimalProduct, newQuantity, newIncome, newCustomer, newDate);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSalesRecord(
      String docId,
      String animalProduct,
      String quantity,
      String income,
      String customer,
      String date,
      ) async {
    await salesCollection.doc(docId).update({
      'animalProduct': animalProduct,
      'quantity': quantity,
      'income': income,
      'customer': customer,
      'date': date,
    });
  }

  Future<void> _deleteSalesRecord(String docId) async {
    await salesCollection.doc(docId).delete();
  }
}
