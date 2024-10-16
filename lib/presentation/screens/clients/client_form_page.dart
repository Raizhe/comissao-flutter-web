import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../../data/models/client_model.dart';
import '../../../widgets/success_dialog.dart';
import 'controllers/clients_controller.dart';

class ClientFormPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();

  // Controladores com máscaras
  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _cpfController = MaskedTextController(mask: '000.000.000-00');
  final _phoneController = MaskedTextController(mask: '(00) 0000-0000');
  final _cellPhoneController = MaskedTextController(mask: '(00) 00000-0000');
  final _stateInscriptionController =
  MaskedTextController(mask: '000.000.000.000');
  final _municipalInscriptionController =
  MaskedTextController(mask: '00000000-0');

  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _projectModelController = TextEditingController();
  final _situationController = TextEditingController();
  final _groupController = TextEditingController();

  final ClientController _clientController = Get.put(ClientController());

  ClientFormPage({Key? key}) : super(key: key);

  Future<void> _addClient() async {
    try {
      // Gerar um ID único para o cliente
      String clientId = const Uuid().v4();

      // Criar o modelo de cliente com os dados preenchidos
      ClientModel client = ClientModel(
        clientId: clientId,
        clientName: _nameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        cellPhone: _cellPhoneController.text.trim(),
        website: _websiteController.text.trim(),
        address: _addressController.text.trim(),
        stateInscription: _stateInscriptionController.text.trim(),
        municipalInscription: _municipalInscriptionController.text.trim(),
        projectModel: _projectModelController.text.trim(),
        preSellerId: 'PRE_SELLER_ID',
        sellerId: 'SELLER_ID',
        contracts: [],
        registeredAt: DateTime.now(),
        situation: _situationController.text.trim(),
        group: _groupController.text.trim(),
        cnpj: _cnpjController.text.trim(),
        cpf: _cpfController.text.trim(),
      );

      // Adicionar o cliente via ClientController
      await _clientController.addClient(client);

      // Mostrar mensagem de sucesso
      SuccessDialog.showSuccess('Cliente cadastrado com sucesso!');

      // Limpar os campos após o cadastro
      _clearFields();

      // Redirecionar para a Home Page
      Get.offAllNamed('/home');
    } catch (e) {
      // Mostrar mensagem de erro
      SuccessDialog.showError('Erro ao cadastrar cliente: $e');
    }
  }

  void _clearFields() {
    _nameController.clear();
    _companyNameController.clear();
    _emailController.clear();
    _cnpjController.updateText('');
    _cpfController.updateText('');
    _phoneController.updateText('');
    _cellPhoneController.updateText('');
    _stateInscriptionController.updateText('');
    _municipalInscriptionController.updateText('');
    _websiteController.clear();
    _addressController.clear();
    _projectModelController.clear();
    _situationController.clear();
    _groupController.clear();
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
              : SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                  const InputDecoration(labelText: 'Nome do Cliente'),
                ),
                TextField(
                  controller: _companyNameController,
                  decoration:
                  const InputDecoration(labelText: 'Razão Social'),
                ),
                TextField(
                  controller: _cnpjController,
                  decoration:
                  const InputDecoration(labelText: 'CNPJ'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration:
                  const InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _cellPhoneController,
                  decoration:
                  const InputDecoration(labelText: 'Celular'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _websiteController,
                  decoration:
                  const InputDecoration(labelText: 'Website'),
                ),
                TextField(
                  controller: _addressController,
                  decoration:
                  const InputDecoration(labelText: 'Endereço'),
                ),
                TextField(
                  controller: _stateInscriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Inscrição Estadual'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _municipalInscriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Inscrição Municipal'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _projectModelController,
                  decoration: const InputDecoration(
                      labelText: 'Modelo de Projeto'),
                ),
                TextField(
                  controller: _cpfController,
                  decoration: const InputDecoration(labelText: 'CPF'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _situationController,
                  decoration: const InputDecoration(
                      labelText: 'Situação (Ativo/Prospeção/Inativo)'),
                ),
                TextField(
                  controller: _groupController,
                  decoration: const InputDecoration(
                      labelText: 'Grupo de Clientes'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addClient,
                  child: const Text('Cadastrar Cliente'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
