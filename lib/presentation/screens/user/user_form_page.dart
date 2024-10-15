import 'package:comissao_flutter_web/presentation/screens/user/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserFormPage extends StatelessWidget {
  UserFormPage({super.key});

  final UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Nome do Usuário'),
            ),
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: controller.roleController,
              decoration: const InputDecoration(labelText: 'Papel (role)'),
            ),
            TextField(
              controller: controller.commissionRateController,
              decoration: const InputDecoration(labelText: 'Taxa de Comissão (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.addUser, // Chama a função de adicionar usuário
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
