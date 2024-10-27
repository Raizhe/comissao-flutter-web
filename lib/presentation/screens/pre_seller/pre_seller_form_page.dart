import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/pre_seller_model.dart';
import '../../../data/repositories/pre_seller_repository.dart';

class PreSellerFormPage extends StatefulWidget {
  const PreSellerFormPage({Key? key}) : super(key: key);

  @override
  _PreSellerFormPageState createState() => _PreSellerFormPageState();
}

class _PreSellerFormPageState extends State<PreSellerFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final PreSellerRepository _preSellerRepository = PreSellerRepository();

  Future<void> _addPreSeller() async {
    try {
      String preSellerId = const Uuid().v4(); // Gerar um ID único
      PreSellerModel preSeller = PreSellerModel(
        preSellerId: preSellerId,
        name: _nameController.text,
        email: _emailController.text,
        comissao: 0.25, // Taxa de comissão padrão
        createdAt: DateTime.now(),
        clients: [],
      );

      // Adicionar pré-vendedor ao Firestore
      await _preSellerRepository.addPreSeller(preSeller);

      // Navegar de volta para a página inicial após o cadastro
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar pré-vendedor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Pré-vendedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPreSeller,
              child: const Text('Cadastrar Pré-vendedor'),
            ),
          ],
        ),
      ),
    );
  }
}
