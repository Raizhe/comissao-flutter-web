// lib/presentation/screens/commissions/commission_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/commission_model.dart';
import '../../../../data/repositories/commission_repository.dart';

class CommissionFormPage extends StatefulWidget {
  const CommissionFormPage({Key? key}) : super(key: key);

  @override
  _CommissionFormPageState createState() => _CommissionFormPageState();
}

class _CommissionFormPageState extends State<CommissionFormPage> {
  final _userIdController = TextEditingController();
  final _contractIdController = TextEditingController();
  final _preSaleIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _paymentStatusController = TextEditingController();

  final CommissionRepository _commissionRepository = CommissionRepository();

  Future<void> _addCommission() async {
    try {
      String commissionId = FirebaseFirestore.instance.collection('commissions').doc().id; // Gerar ID automaticamente
      CommissionModel newCommission = CommissionModel(
        commissionId: commissionId,
        userId: _userIdController.text.trim(),
        contractId: _contractIdController.text.trim(),
        preSaleId: _preSaleIdController.text.isNotEmpty ? _preSaleIdController.text.trim() : null,
        amount: double.parse(_amountController.text.trim()),
        commissionRate: double.parse(_commissionRateController.text.trim()),
        calculatedAt: DateTime.now(),
        paymentStatus: _paymentStatusController.text.trim(),
      );

      await _commissionRepository.addCommission(newCommission);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comissão cadastrada com sucesso!')),
      );

      // Voltar para a página inicial após o cadastro
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar comissão: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Comissão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: 'ID do Usuário'),
            ),
            TextField(
              controller: _contractIdController,
              decoration: const InputDecoration(labelText: 'ID do Contrato'),
            ),
            TextField(
              controller: _preSaleIdController,
              decoration: const InputDecoration(labelText: 'ID da Pré-venda'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Valor da Comissão'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _commissionRateController,
              decoration: const InputDecoration(labelText: 'Taxa de Comissão (%)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _paymentStatusController,
              decoration: const InputDecoration(labelText: 'Status de Pagamento (pago/pendente)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCommission,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
