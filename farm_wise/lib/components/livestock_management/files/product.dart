import 'package:farm_wise/components/livestock_management/files/specificproduct.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final CollectionReference productsCollection =
  FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: productsCollection.orderBy('name').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No products found"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddProductDialog,
                    child: const Text("Add Product"),
                  ),
                ],
              ),
            );
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String productName = data['name'] ?? 'Unnamed Product';
                final String formattedName = _capitalize(productName);

                return Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      formattedName,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditProductDialog(doc.id, formattedName),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteProduct(doc.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the Generic Details Page with the product ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Specificproduct(productName: formattedName, productId: doc.id),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _capitalize(String name) {
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Future<void> _showAddProductDialog() async {
    String productName = "";

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => productName = value,
                  decoration: const InputDecoration(labelText: "Product Name"),
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
                  Navigator.pop(context); // Close the dialog immediately
                  if (productName.isNotEmpty) {
                    final productExists = await _checkProductExists(productName);
                    if (productExists) {
                      // Show the message if the product already exists
                      _showProductExistsMessage(productName);
                    } else {
                      await _addProduct(productName);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product name cannot be empty")),
                    );
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

  Future<bool> _checkProductExists(String name) async {
    final querySnapshot = await productsCollection
        .where('name', isEqualTo: name)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _addProduct(String name) async {
    await productsCollection.add({
      'name': name,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product added successfully")),
    );
  }

  Future<void> _showEditProductDialog(String docId, String currentName) async {
    String productName = currentName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: productName),
              onChanged: (value) => productName = value,
              decoration: const InputDecoration(labelText: "Product Name"),
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
              _editProduct(docId, productName);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _editProduct(String docId, String name) async {
    if (name.isNotEmpty) {
      await productsCollection.doc(docId).update({
        'name': name,
      });
    }
  }

  Future<void> _deleteProduct(String docId) async {
    await productsCollection.doc(docId).delete();
  }

  // Method to show the "Product already exists" message centered on the screen
  void _showProductExistsMessage(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text('$productName already exists'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
