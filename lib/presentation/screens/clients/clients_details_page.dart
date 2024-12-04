import 'package:flutter/material.dart';
import 'package:comissao_flutter_web/data/models/clients_model.dart';
import 'package:get/get.dart';
import '../clients/controllers/clients_controller.dart';

class ClientDetailsPage extends StatefulWidget {
  final ClientModel? client; // Tornando o parâmetro opcional para tratar nulos.

  const ClientDetailsPage({Key? key, this.client}) : super(key: key);

  @override
  _ClientDetailsPageState createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  final ClientsController _clientsController = Get.put(ClientsController());
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    // Define o status atual ou "Desconhecido" se o cliente for nulo.
    currentStatus = widget.client?.status ?? 'Desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o cliente é nulo e exibe uma mensagem apropriada.
    if (widget.client == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Cliente'),
        ),
        body: const Center(
          child: Text(
            'Erro: Cliente não fornecido.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.client!.nome}'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildScrollableTable(),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusDropdown(),
                  ],
                ),
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
    // Garantindo que os valores sejam tratados corretamente mesmo que sejam nulos.
    return [
      _buildTableRow('Nome', widget.client!.nome),
      _buildTableRow('CNPJ', widget.client!.cpfcnpj ?? 'Não disponível'),
      _buildTableRow('Inscrição Estadual', widget.client!.inscricaoEstadual ?? 'Não disponível'),
      _buildTableRow('Email', widget.client!.email ?? 'Não disponível'),
      _buildTableRow('Telefone', widget.client!.telefone ?? 'Não disponível'),
      _buildTableRow('Rua', widget.client!.rua ?? 'Não disponível'),
      _buildTableRow('Número', widget.client!.numero?.toString() ?? 'Não disponível'),
      _buildTableRow('Complemento', widget.client!.complemento ?? 'Não disponível'),
      _buildTableRow('Bairro', widget.client!.bairro ?? 'Não disponível'),
      _buildTableRow('Cidade', widget.client!.cidade ?? 'Não disponível'),
      _buildTableRow('Estado', widget.client!.estado ?? 'Não disponível'),
      _buildTableRow('CEP', widget.client!.cep ?? 'Não disponível'),
      _buildTableRow('País', widget.client!.pais ?? 'Não disponível'),
      _buildTableRow('Data da Venda', widget.client!.dataVenda?.toString() ?? 'Não disponível'),
      _buildTableRow('Data Retroativa', widget.client!.dataRetroativa?.toString() ?? 'Não disponível'),
      _buildTableRow('Status', currentStatus),
      _buildTableRow('Registrado em', _formatDate(widget.client!.registeredAt)),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não disponível';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatusDropdown() {
    final List<String> statuses = [
      'Ativo',
      'Cancelado',
      'Downsell',
      'Encerramento',
      'Inativo',
      'Renovado',
      'Renovação Automática',
      'Upsell',
    ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Alterar Status do Cliente:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: getStatusColor(currentStatus).withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: currentStatus,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: getStatusColor(currentStatus), fontSize: 16),
              underline: Container(
                height: 2,
                color: getStatusColor(currentStatus),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentStatus = newValue;
                  });
                  _clientsController.updateClientStatus(widget.client!, newValue);
                  Get.snackbar(
                    'Status Atualizado',
                    'Cliente definido como $newValue.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: getStatusColor(newValue).withOpacity(0.8),
                    colorText: Colors.white,
                  );
                }
              },
              items: statuses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

  // Método para obter a cor do status
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ATIVO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      case 'DOWNSSELL':
        return Colors.orange;
      case 'ENCERRAMENTO':
        return Colors.yellow[700]!;
      case 'INATIVO':
        return Colors.grey;
      case 'RENOVADO':
        return Colors.purple;
      case 'RENOVAÇÃO AUTOMÁTICA':
        return Colors.purple[200]!;
      case 'UPSELL':
        return Colors.green;
      case 'PAUSADO':
        return Colors.blue;
      default:
        return Colors.grey.shade300;
    }
  }
}
