import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../../data/models/clients_model.dart';
import '../../../widgets/success_dialog.dart';
import 'controllers/clients_controller.dart';

class ClientFormPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();

  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _cpfController = MaskedTextController(mask: '000.000.000-00');
  final _phoneController = MaskedTextController(mask: '(00) 0000-0000');
  final _cellPhoneController = MaskedTextController(mask: '(00) 00000-0000');
  final _stateInscriptionController = MaskedTextController(mask: '000.000.000.000');
  final _municipalInscriptionController = MaskedTextController(mask: '00000000-0');

  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _projectModelController = TextEditingController();
  final _situationController = TextEditingController();
  final _groupController = TextEditingController();

  final ClientsController _clientController = Get.put(ClientsController());

  ClientFormPage({Key? key}) : super(key: key);

  Future<void> _addClient() async {
    try {
      String clientId = const Uuid().v4();

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

      await _clientController.addClient(client);

      SuccessDialog.showSuccess('Cliente cadastrado com sucesso!');
      _clearFields();
      Get.offAllNamed('/home');
    } catch (e) {
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
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600, // Define a largura do card
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cadastro de Cliente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormGrid(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: _addClient,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dois campos por linha
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      children: [
        _buildTextField(_nameController, 'Nome do Cliente'),
        _buildTextField(_companyNameController, 'Razão Social'),
        _buildTextField(_cnpjController, 'CNPJ', TextInputType.number),
        _buildTextField(_cpfController, 'CPF', TextInputType.number),
        _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
        _buildTextField(_phoneController, 'Telefone', TextInputType.phone),
        _buildTextField(_cellPhoneController, 'Celular', TextInputType.phone),
        _buildTextField(_websiteController, 'Website'),
        _buildTextField(_addressController, 'Endereço'),
        _buildTextField(_stateInscriptionController, 'Inscrição Estadual'),
        _buildTextField(_municipalInscriptionController, 'Inscrição Municipal'),
        _buildTextField(_projectModelController, 'Modelo de Projeto'),
        _buildTextField(_situationController, 'Situação'),
        _buildTextField(_groupController, 'Grupo de Clientes'),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, [TextInputType? type]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
