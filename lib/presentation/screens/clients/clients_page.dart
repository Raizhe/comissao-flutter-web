import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/clients_model.dart';
import 'controllers/clients_controller.dart';

class ClientsPage extends StatelessWidget {
  final ClientsController _clientsController = Get.put(ClientsController());

  ClientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (_clientsController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_clientsController.clients.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cliente encontrado.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Exibe clientes em uma grade centralizada e elegante
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Duas colunas na grade
                  crossAxisSpacing: 16.0, // Espaço entre colunas
                  mainAxisSpacing: 16.0, // Espaço entre linhas
                  childAspectRatio: 3 / 2, // Proporção do card
                ),
                itemCount: _clientsController.clients.length,
                itemBuilder: (context, index) {
                  final client = _clientsController.clients[index];
                  return _buildClientCard(client);
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  // Widget para construir um card de cliente
  Widget _buildClientCard(ClientModel client) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Bordas arredondadas
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              client.clientName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Empresa: ${client.companyName}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Telefone: ${client.phone ?? "Não disponível"}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Situação: ${client.situation}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool confirm = await _showDeleteConfirmationDialog();
                  if (confirm) {
                    await _clientsController.deleteClient(client.clientId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo de confirmação para excluir cliente
  Future<bool> _showDeleteConfirmationDialog() async {
    return await Get.defaultDialog(
      title: 'Excluir Cliente',
      middleText: 'Tem certeza que deseja excluir este cliente?',
      textCancel: 'Cancelar',
      textConfirm: 'Confirmar',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
  }
}
