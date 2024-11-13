import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductPageState();
}

class _ProductPageState extends State<Products> {
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
        stream: productsCollection.snapshots(),
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
      builder: (context) => AlertDialog(
        title: const Text("Add Product"),
        content: TextField(
          onChanged: (value) => productName = value,
          decoration: const InputDecoration(labelText: "Product Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addProduct(productName);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProductDialog(String docId, String currentName) async {
    String productName = currentName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Product"),
        content: TextField(
          controller: TextEditingController(text: productName),
          onChanged: (value) => productName = value,
          decoration: const InputDecoration(labelText: "Product Name"),
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

  Future<void> _addProduct(String name) async {
    if (name.isNotEmpty) {
      await productsCollection.add({
        'name': name,
      });
    }
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
}
