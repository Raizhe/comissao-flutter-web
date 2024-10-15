import 'package:comissao_flutter_web/presentation/screens/seller/controllers/seller_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerFormPage extends StatelessWidget {
  SellerFormPage({Key? key}) : super(key: key);

  final SellerController controller = Get.put(SellerController()); // Crie a instância do controller

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
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Nome do Vendedor'),
            ),
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email do Vendedor'),
            ),
            TextField(
              controller: controller.commissionRateController,
              decoration: const InputDecoration(labelText: 'Taxa de Comissão (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.addSeller, // Chama a função da controller
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
