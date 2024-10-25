import 'package:flutter/material.dart';
import 'package:comissao_flutter_web/data/models/clients_model.dart';

class ClientDetailsPage extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${client.clientName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildScrollableTable(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableTable() {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(200.0),
          1: FlexColumnWidth(),
        },
        border: TableBorder(
          horizontalInside: BorderSide(width: 1, color: Colors.grey[300]!),
          verticalInside: BorderSide(width: 1, color: Colors.grey[300]!),
        ),
        children: _buildTableRows(),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    return [
      _buildTableRow('Nome', client.clientName),
      _buildTableRow('Empresa', client.companyName),
      _buildTableRow('Email', client.clientEmail ?? 'Não disponível'),
      _buildTableRow('Telefone', client.phone ?? 'Não disponível'),
      _buildTableRow('Celular', client.cellPhone ?? 'Não disponível'),
      _buildTableRow('Website', client.website ?? 'Não disponível'),
      _buildTableRow('Endereço', client.address ?? 'Não disponível'),
      _buildTableRow('Inscrição Estadual', client.stateInscription ?? 'Não disponível'),
      _buildTableRow('Inscrição Municipal', client.municipalInscription ?? 'Não disponível'),
      _buildTableRow('Modelo de Projeto', client.projectModel ?? 'Não disponível'),
      _buildTableRow('ID do Pré-vendedor', client.preSellerId ?? 'Não disponível'),
      _buildTableRow('ID do Vendedor', client.sellerId ?? 'Não disponível'),
      _buildTableRow('CNPJ', client.cnpj ?? 'Não disponível'),
      _buildTableRow('CPF', client.cpf ?? 'Não disponível'),
      _buildTableRow('Grupo', client.group ?? 'Não disponível'),
      _buildTableRow('Situação', client.situation),
      _buildTableRow('Registrado em', _formatDate(client.registeredAt)),
    ];
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
