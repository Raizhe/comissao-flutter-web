import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/contract_model.dart';
import 'controllers/contracts_controller.dart';

class ContractsPage extends StatelessWidget {
  final ContractController _contractController = Get.put(ContractController());

  ContractsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _contractController.fetchContracts(); // Garante a busca dos contratos

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
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
              return _buildContractCard(context, contract);
            },
          );
        }),
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, ContractModel contract) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800), // Limita a largura máxima
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
          onTap: () {
            // Navegar para a tela de detalhes do contrato
            Get.toNamed('/contracts_details', arguments: contract);
          },

          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                  _buildDetailRow('Tipo', contract.type),
                  _buildDetailRow(
                    'Valor',
                    'R\$${contract.amount.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                  _buildDetailRow('Status', contract.status, color: Colors.blue),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para exibir uma linha de detalhe
  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color ?? Colors.black),
          ),
        ],
      ),
    );
  }
}
