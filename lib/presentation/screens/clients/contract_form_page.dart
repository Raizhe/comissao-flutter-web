// lib/presentation/screens/contracts/contract_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/repositories/contract_repository.dart';

class ContractFormPage extends StatefulWidget {
  const ContractFormPage({Key? key}) : super(key: key);

  @override
  _ContractFormPageState createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  final _clientIdController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _sellerIdController = TextEditingController();
  final _preSellerIdController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _renewalTypeController = TextEditingController();
  // final _contractCSController = TextEditingController();
  // final _projectManagerController = TextEditingController();

  final ContractRepository _contractRepository = ContractRepository();

  Future<void> _addContract() async {
    try {
      String contractId = FirebaseFirestore.instance.collection('contracts').doc().id; // Gerar ID automaticamente
      ContractModel newContract = ContractModel(
        contractId: contractId,
        clientId: _clientIdController.text.trim(),
        clientName: _clientNameController.text.trim(),
        sellerId: _sellerIdController.text.trim(),
        preSellerId: _preSellerIdController.text.trim(),
        type: _typeController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        startDate: DateTime.now(),
        endDate: _endDateController.text.isNotEmpty ? DateTime.parse(_endDateController.text) : null,
        status: 'active',
        createdAt: DateTime.now(),
        paymentMethod: _paymentMethodController.text.trim(),
        installments: int.parse(_installmentsController.text.trim()),
        renewalType: _renewalTypeController.text.trim(),
        salesOrigin: _sellerIdController.text.trim(),
        preSalesOrigin: _preSellerIdController.text.trim(),
        // contractCS: _contractCSController.text.trim(),
        // projectManager: _projectManagerController.text.trim(),
      );

      await _contractRepository.addContract(newContract);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrato cadastrado com sucesso!')),
      );

      // Voltar para a página inicial após o cadastro
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar contrato: $e')),
      );
    }
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
              decoration: const InputDecoration(labelText: 'ID do Pré-Vendedor'),
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Tipo (monthly_fee ou one_time_job)'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _installmentsController,
              decoration: const InputDecoration(labelText: 'Número de Parcelas'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
            ),
            TextField(
              controller: _renewalTypeController,
              decoration: const InputDecoration(labelText: 'Tipo de Renovação (automático/manual)'),
            ),
            // TextField(
            //   controller: _contractCSController,
            //   decoration: const InputDecoration(labelText: 'ID do CS'),
            // ),
            // TextField(
            //   controller: _projectManagerController,
            //   decoration: const InputDecoration(labelText: 'ID do Gerente de Projeto'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addContract,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
