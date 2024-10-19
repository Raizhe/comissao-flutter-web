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

          // Exibe os clientes em uma lista centralizada e compacta
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // Limita a largura
              child: ListView.builder(
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
    return InkWell(
      onTap: () {
        Get.toNamed('/client_details', arguments: client); // Navega para os detalhes
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0), // Espaço entre os cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bordas arredondadas
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  icon: const Icon(Icons.settings, color: Colors.grey),
                  onPressed: () {
                    Get.toNamed('/client_form', arguments: client); // Editar cliente
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
