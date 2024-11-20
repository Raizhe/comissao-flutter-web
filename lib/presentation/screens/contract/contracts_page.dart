import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/contracts_controller.dart';
import '../../../data/models/contract_model.dart';

class ContractsPage extends StatelessWidget {
  final ContractController _contractController = Get.put(ContractController());

  ContractsPage({Key? key}) : super(key: key);

  void _showContractOptionsModal(BuildContext context, ContractModel contract) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opções do Contrato'),
          content: const Text('Escolha uma ação para este contrato.'),
          actions: [
            TextButton(
              onPressed: () {
                _contractController.updateContractStatus(contract, 'Pausado');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Pausar',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                _contractController.updateContractStatus(contract, 'Cancelado');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _contractController.updateContractStatus(contract, 'Ativo');
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
        title: const Text('Contratos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/contract_form');
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
                              hintText: 'Buscar por cliente, tipo ou status',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (query) {
                              _contractController.searchContracts(query);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (value) {
                            _contractController.sortContracts(value == 'A-Z');
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
                        if (_contractController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (_contractController.contracts.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhum contrato encontrado.',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }

                        return _buildContractsTable(context);
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

  Widget _buildContractsTable(BuildContext context) {
    final contracts = _contractController.contracts;
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
          const DataColumn(label: Text('Cliente')),
          if (!isCompact) const DataColumn(label: Text('Tipo')),
          if (!isCompact) const DataColumn(label: Text('Valor')),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Ações')),
        ],
        rows: contracts.map((contract) {
          return DataRow(
            cells: [
              _buildClientNameCell(contract),
              if (!isCompact) DataCell(Text(contract.type)),
              if (!isCompact)
                DataCell(Text('R\$${contract.amount.toStringAsFixed(2)}')),
              DataCell(
                Text(
                  contract.status,
                  style: TextStyle(
                    color: _getStatusColor(contract.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showContractOptionsModal(context, contract);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  DataCell _buildClientNameCell(ContractModel contract) {
    bool isHovered = false;

    return DataCell(
      StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: () {
                Get.toNamed('/contracts_details', arguments: contract);
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
                child: Text(contract.clientName),
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
