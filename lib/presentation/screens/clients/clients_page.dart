import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'controllers/clients_controller.dart';
import '../../../data/models/clients_model.dart';

class ClientsPage extends StatelessWidget {
  final ClientsController _clientsController = Get.put(ClientsController());

  ClientsPage({Key? key}) : super(key: key);

  void _showClientOptionsModal(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opções do Cliente'),
          content: const Text('Escolha uma ação para este cliente.'),
          actions: [
            TextButton(
              onPressed: () {
                _clientsController.updateClientStatus(client, 'Pausado');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Pausar',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                _clientsController.updateClientStatus(client, 'Cancelado');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _clientsController.updateClientStatus(client, 'Ativo');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ativar',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/client_form');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Buscar por nome, CNPJ/CPF ou status',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (query) {
                              _clientsController.searchClients(query);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (value) {
                            _clientsController.sortClients(value == 'A-Z');
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'A-Z',
                              child: Text('Ordenar A-Z'),
                            ),
                            const PopupMenuItem(
                              value: 'Z-A',
                              child: Text('Ordenar Z-A'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
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

                        return _buildClientsTable(context);
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientsTable(BuildContext context) {
    final clients = _clientsController.clients;
    final maxWidth = MediaQuery.of(context).size.width;
    final isCompact = maxWidth < 600;

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: isCompact ? 20 : 50,
        headingRowHeight: 40,
        border: TableBorder(
          verticalInside: BorderSide(
            width: 1,
            color: Colors.grey.shade300,
          ),
        ),
        columns: [
          const DataColumn(label: Text('Nome')),
          if (!isCompact) const DataColumn(label: Text('CNPJ/CPF')),
          if (!isCompact) const DataColumn(label: Text('Telefone')),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Ações')),
        ],
        rows: clients.map((client) {
          return DataRow(
            cells: [
              _buildClientNameCell(client),
              if (!isCompact) DataCell(Text(client.cpfcnpj ?? 'Não disponível')),
              if (!isCompact) DataCell(Text(client.telefone ?? 'Não disponível')),
              DataCell(
                Text(
                  client.status,
                  style: TextStyle(
                    color: _getStatusColor(client.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showClientOptionsModal(context, client);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  DataCell _buildClientNameCell(ClientModel client) {
    bool isHovered = false;

    return DataCell(
      StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: () {
                Get.toNamed('/client_details', arguments: client);
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
                child: Text(client.nome),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'pausado':
        return Colors.orange;
      default:
        return Colors.grey; // Cor padrão para status indefinidos
    }
  }
}
