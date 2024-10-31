import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/contract_model.dart';

class ContractDetailsPage extends StatelessWidget {
  final ContractModel contract;
  final String sellerName;
  final String? preSellerName;
  final String? operatorName;

  const ContractDetailsPage({
    Key? key,
    required this.contract,
    required this.sellerName,
    this.preSellerName,
    this.operatorName,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não disponível';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Contrato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(200.0),
                      1: FlexColumnWidth(),
                    },
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    children: _buildTableRows(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    return [
      _buildTableRow('ID do Contrato', contract.contractId),
      _buildTableRow('Cliente', contract.clientName),
      _buildTableRow('CNPJ', contract.clientCNPJ),
      _buildTableRow('Endereço', contract.address),
      _buildTableRow('Telefone', contract.telefone),
      _buildTableRow('E-mail Financeiro', contract.emailFinanceiro),
      _buildTableRow('Representante Legal', contract.representanteLegal),
      _buildTableRow('CPF do Representante', contract.cpfRepresentante),
      _buildTableRow('Vendedor', sellerName),
      _buildTableRow('Pré-Vendedor', preSellerName ?? 'N/A'),
      _buildTableRow('Operador', operatorName ?? 'N/A'),
      _buildTableRow('Tipo de Contrato', contract.type),
      _buildTableRow('Valor', 'R\$${contract.amount.toStringAsFixed(2)}'),
      _buildTableRow('Parcelas', contract.installments.toString()),
      _buildTableRow('Fee Mensal', 'R\$${contract.feeMensal.toStringAsFixed(2)}'),
      _buildTableRow('Forma de Pagamento', contract.paymentMethod),
      _buildTableRow('Status', contract.status),
      _buildTableRow('Início', _formatDate(contract.startDate)),
      _buildTableRow('Término', _formatDate(contract.endDate)),
      _buildTableRow('Tipo de Renovação', contract.renewalType),
      _buildTableRow('Origem da Venda', contract.salesOrigin),
      _buildTableRow('Customer Success', contract.costumerSuccess ?? 'N/A'),
      _buildTableRow('Observações', contract.observacoes ?? 'Sem observações'),
    ];
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
