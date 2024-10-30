import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'customer_success_controller.dart';

class CustomerSuccessFormPage extends StatelessWidget {
  CustomerSuccessFormPage({super.key});

  final CustomerSuccessController controller = Get.put(CustomerSuccessController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Customer Success'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600, // Card mais estreito para centralizar a interface
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
                        'Cadastro de Customer Success',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormGrid(), // Grade de campos de texto
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: controller.addCustomerSuccess,
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
        _buildTextField(controller.nameController, 'Nome'),
        _buildTextField(controller.emailController, 'Email', TextInputType.emailAddress),
        _buildTextField(
          controller.createdAtController,
          'Data de Criação',
          TextInputType.datetime,
          true, // Define o campo como somente leitura
        ),
      ],
    );
  }


  Widget _buildTextField(
      TextEditingController controller, String label,
      [TextInputType? type, bool readOnly = false]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

}
