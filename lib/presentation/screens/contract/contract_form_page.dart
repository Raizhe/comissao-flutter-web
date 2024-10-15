import 'package:comissao_flutter_web/presentation/screens/contract/controllers/contracts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/contract_model.dart';


class ContractFormPage extends StatelessWidget {
  final ContractController _contractController = Get.put(ContractController());

  final _clientIdController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _sellerIdController = TextEditingController();
  final _preSellerIdController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _renewalTypeController = TextEditingController();
  final _salesOriginController = TextEditingController();
  final _preSalesOriginController = TextEditingController();

  ContractFormPage({super.key});

  Future<void> _addContract() async {
    String contractId = const Uuid().v4();

    ContractModel newContract = ContractModel(
      contractId: contractId,
      clientId: _clientIdController.text.trim(),
      clientName: _clientNameController.text.trim(),
      sellerId: _sellerIdController.text.trim(),
      preSellerId: _preSellerIdController.text.trim(),
      type: _typeController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      startDate: DateTime.now(),
      endDate: null, // Adicione a lógica para escolher uma data final se necessário
      status: 'ativo', // Definir status inicial
      createdAt: DateTime.now(),
      paymentMethod: _paymentMethodController.text.trim(),
      installments: int.parse(_installmentsController.text.trim()),
      renewalType: _renewalTypeController.text.trim(),
      salesOrigin: _salesOriginController.text.trim(),
      preSalesOrigin: _preSalesOriginController.text.trim(),
    );

    await _contractController.addContract(newContract);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Contrato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _clientIdController,
              decoration: const InputDecoration(labelText: 'ID do Cliente'),
            ),
            TextField(
              controller: _clientNameController,
              decoration: const InputDecoration(labelText: 'Nome do Cliente'),
            ),
            TextField(
              controller: _sellerIdController,
              decoration: const InputDecoration(labelText: 'ID do Vendedor'),
            ),
            TextField(
              controller: _preSellerIdController,
              decoration: const InputDecoration(labelText: 'ID do Pré-vendedor'),
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Tipo de Contrato'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
            ),
            TextField(
              controller: _installmentsController,
              decoration: const InputDecoration(labelText: 'Parcelas'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _renewalTypeController,
              decoration: const InputDecoration(labelText: 'Tipo de Renovação'),
            ),
            TextField(
              controller: _salesOriginController,
              decoration: const InputDecoration(labelText: 'Origem da Venda'),
            ),
            TextField(
              controller: _preSalesOriginController,
              decoration: const InputDecoration(labelText: 'Origem da Pré-venda'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addContract,
              child: const Text('Cadastrar Contrato'),
            ),
          ],
        ),
      ),
    );
  }
}
