import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/client_model.dart';
import 'controllers/clients_controller.dart'; // O Controller que criamos

class ClientFormPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ClientController _clientController = Get.put(ClientController()); // Instanciando o Controller

  ClientFormPage({Key? key}) : super(key: key);

  Future<void> _addClient() async {
    // Gerar um ID único para o cliente
    String clientId = const Uuid().v4();

    // Criar o modelo de cliente com os dados preenchidos
    ClientModel client = ClientModel(
      clientId: clientId,
      clientName: _nameController.text.trim(),
      clientEmail: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      preSellerId: 'PRE_SELLER_ID', // Substitua pelo ID do pré-vendedor logado
      sellerId: 'SELLER_ID', // Substitua pelo ID do vendedor responsável
      contracts: [],
      registeredAt: DateTime.now(),
    );

    // Adicionar o cliente via ClientController
    await _clientController.addClient(client);

    // Limpar os campos após o cadastro
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();

    // Navegar de volta à página anterior
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return _clientController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addClient,
                child: const Text('Cadastrar Cliente'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
