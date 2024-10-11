import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SellerFormPage extends StatefulWidget {
  const SellerFormPage({Key? key}) : super(key: key);

  @override
  _SellerFormPageState createState() => _SellerFormPageState();
}

class _SellerFormPageState extends State<SellerFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final CollectionReference sellersRef = FirebaseFirestore.instance.collection('sellers');

  Future<void> _addSeller() async {
    try {
      String sellerId = const Uuid().v4();
      await sellersRef.doc(sellerId).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'commissionRate': double.parse(_commissionRateController.text.trim()),
        'createdAt': Timestamp.now(),
        'contracts': [],
        'clients': [],
      });
      Navigator.pop(context); // Voltar para a página anterior (página inicial)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar vendedor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Vendedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Vendedor'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email do Vendedor'),
            ),
            TextField(
              controller: _commissionRateController,
              decoration: const InputDecoration(labelText: 'Taxa de Comissão (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSeller,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
