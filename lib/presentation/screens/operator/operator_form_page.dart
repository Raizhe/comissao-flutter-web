import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/repositories/operator_repository.dart';

class OperatorFormPage extends StatelessWidget {
  final OperatorRepository _operatorRepository = OperatorRepository();

  // Controladores dos campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();

  OperatorFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Operador'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600, // Definição da largura do card
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
                        'Cadastro de Operador',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormGrid(), // Formulário
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: addOperator, // Função para adicionar operador
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

  // Grid com os campos do formulário
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
        _buildTextField(_nameController, 'Nome do Operador'),
        _buildTextField(
          _emailController,
          'Email',
          TextInputType.emailAddress,
        ),
        _buildTextField(
          _commissionController,
          'Comissão (%)',
          TextInputType.number,
        ),
      ],
    );
  }

  // Widget para construir os campos de texto
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

  // Função para validar os inputs do formulário
  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _commissionController.text.trim().isEmpty) {
      Get.snackbar('Erro', 'Todos os campos são obrigatórios.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (!_isEmailValid(_emailController.text.trim())) {
      Get.snackbar('Erro', 'Por favor, insira um email válido.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    return true;
  }

  // Função para validar se o email está no formato correto
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  // Função para adicionar o operador ao banco de dados
  Future<void> addOperator() async {
    if (!_validateInputs()) return;

    try {
      OperatorModel operator = OperatorModel(
        operatorId: const Uuid().v4(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        commission: double.parse(_commissionController.text.trim()),
        createdAt: Timestamp.fromDate(DateTime.now()),
      );

      await _operatorRepository.addOperator(operator);
      Get.snackbar('Sucesso', 'Operador cadastrado com sucesso!',
          backgroundColor: Colors.green, colorText: Colors.white);

      // Redirecionar para a home após o cadastro
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar operador: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
