import 'package:flutter/material.dart';
import 'package:comissao_flutter_web/data/models/clients_model.dart';

class ClientDetailsPage extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${client.nome}'),
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
      _buildTableRow('Nome', client.nome),
      _buildTableRow('CNPJ', client.cpfcnpj ?? 'Não disponível'),
      _buildTableRow('Inscrição Estadual', client.inscricaoEstadual ?? 'Não disponível'),
      _buildTableRow('Email', client.email ?? 'Não disponível'),
      _buildTableRow('Telefone', client.telefone ?? 'Não disponível'),
      _buildTableRow('Rua', client.rua ?? 'Não disponível'),
      _buildTableRow('Número', client.numero?.toString() ?? 'Não disponível'),
      _buildTableRow('Complemento', client.complemento ?? 'Não disponível'),
      _buildTableRow('Bairro', client.bairro ?? 'Não disponível'),
      _buildTableRow('Cidade', client.cidade ?? 'Não disponível'),
      _buildTableRow('Estado', client.estado ?? 'Não disponível'),
      _buildTableRow('CEP', client.cep ?? 'Não disponível'),
      _buildTableRow('País', client.pais ?? 'Não disponível'),
      _buildTableRow('Código do Produto', client.codigoProduto?.toString() ?? 'Não disponível'),
      _buildTableRow('Nome do Produto', client.nomeProduto ?? 'Não disponível'),
      _buildTableRow('Valor Unitário', client.valorUnitario ?? 'Não disponível'),
      _buildTableRow('Quantidade', client.quantidade?.toString() ?? 'Não disponível'),
      _buildTableRow('NCM', client.ncm?.toString() ?? 'Não disponível'),
      _buildTableRow('Natureza', client.natureza?.toString() ?? 'Não disponível'),
      _buildTableRow('Código de Venda', client.codigoVenda?.toString() ?? 'Não disponível'),
      _buildTableRow('Data da Venda', client.dataVenda?.toString() ?? 'Não disponível'),
      _buildTableRow('Data Retroativa', client.dataRetroativa?.toString() ?? 'Não disponível'),
      _buildTableRow('status', client.status),
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
