import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/contract_model.dart';

class ContractDetailsPage extends StatelessWidget {
  final ContractModel contract;
  final String sellerName;

  const ContractDetailsPage({
    Key? key,
    required this.contract,
    required this.sellerName,
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(200.0),
                    1: FlexColumnWidth(),
                  },
                  border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                  children: _buildTableRows(),
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
      _buildTableRow('Cliente', contract.clientName),
      _buildTableRow('Vendedor', sellerName),
      _buildTableRow('Tipo', contract.type),
      _buildTableRow('Valor', 'R\$${contract.amount.toStringAsFixed(2)}'),
      _buildTableRow('Status', contract.status),
      _buildTableRow('Início', _formatDate(contract.startDate)),
      _buildTableRow('Término', _formatDate(contract.endDate)),
    ];
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(child: Text(value)),
        ),
      ],
    );
  }
}
