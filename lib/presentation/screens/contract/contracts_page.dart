import 'package:comissao_flutter_web/presentation/screens/contract/controllers/contracts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/contract_model.dart';

class ContractsPage extends StatelessWidget {
  final ContractController _contractController = Get.put(ContractController());

  ContractsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Garante que os contratos sejam buscados quando a página é carregada
    _contractController.fetchContracts();

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

          return ListView.builder(
            itemCount: _contractController.contracts.length,
            itemBuilder: (context, index) {
              final contract = _contractController.contracts[index];
              return _buildContractCard(contract);
            },
          );
        }),
      ),
    );
  }

  Widget _buildContractCard(ContractModel contract) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contract.clientName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${contract.type}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Valor: R\$${contract.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${contract.status}',
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Get.toNamed('/contract_form', arguments: contract);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirm = await _showDeleteConfirmationDialog();
                    if (confirm) {
                      await _contractController.deleteContract(contract.contractId);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await Get.defaultDialog(
      title: 'Excluir Contrato',
      middleText: 'Tem certeza que deseja excluir este contrato?',
      textCancel: 'Cancelar',
      textConfirm: 'Confirmar',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
  }
}
