import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/seller_model.dart';
import '../../../data/repositories/seller_repository.dart';

class SellerFormPage extends StatefulWidget {
  @override
  _SellerFormPageState createState() => _SellerFormPageState();
}

class _SellerFormPageState extends State<SellerFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final SellerRepository _sellerRepository = SellerRepository();

  bool _isLoading = false;

  Future<void> _addSeller() async {
    if (_nameController.text.trim().isEmpty ||
        _commissionRateController.text.trim().isEmpty) {
      Get.snackbar(
        'Erro',
        'Por favor, preencha todos os campos obrigatórios.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      String sellerId = const Uuid().v4();

      SellerModel newSeller = SellerModel(
        sellerId: sellerId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        commissionRate: double.parse(_commissionRateController.text.trim()),
        createdAt: Timestamp.fromDate(DateTime.now()),

    contracts: [],
        clients: [],
      );

      await _sellerRepository.addSeller(newSeller);

      Get.snackbar(
        'Sucesso',
        'Vendedor cadastrado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao cadastrar vendedor: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Vendedor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cadastro de Vendedor',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commissionRateController,
                      decoration: const InputDecoration(
                        labelText: 'Taxa de Comissão (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSeller,
                        style: ElevatedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cadastrar Vendedor'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
