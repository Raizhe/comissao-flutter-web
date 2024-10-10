import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/client_model.dart';
import '../../../data/repositories/client_repository.dart';


class ClientFormPage extends StatefulWidget {
  const ClientFormPage({Key? key}) : super(key: key);

  @override
  _ClientFormPageState createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ClientRepository _clientRepository = ClientRepository();

  Future<void> _addClient() async {
    try {
      // Gerar um ID único para o cliente
      String clientId = const Uuid().v4();

      // Criar o modelo de cliente com os dados preenchidos
      ClientModel client = ClientModel(
        clientId: clientId,
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        preSellerId: 'PRE_SELLER_ID', // Aqui você pode substituir pelo ID do pré-vendedor logado
        sellerId: 'SELLER_ID', // Substitua pelo ID do vendedor responsável
        contracts: [],
        registeredAt: DateTime.now(),
      );

      // Adicionar o cliente ao Firestore
      await _clientRepository.addClient(client);

      // Exibir mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente cadastrado com sucesso!')),
      );

      // Limpar os campos após o cadastro
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();

      // Voltar para a página inicial após o cadastro
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
        ),
      ),
    );
  }
}
