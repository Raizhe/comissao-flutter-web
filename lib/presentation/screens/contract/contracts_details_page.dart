import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importação para formatação de datas
import '../../../data/models/contract_model.dart';

class ContractDetailsPage extends StatelessWidget {
  final ContractModel contract;

  const ContractDetailsPage({Key? key, required this.contract}) : super(key: key);

  // Função para formatar as datas de tipo DateTime
  String _formatDate(DateTime? date) {
    if (date == null) return 'Não disponível';
    return DateFormat('dd/MM/yyyy').format(date); // Formato: dd/MM/yyyy
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contrato: ${contract.clientName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('ID do Contrato', contract.contractId),
                      _buildDetailRow('CNPJ do Cliente', contract.clientCNPJ),
                      _buildDetailRow('Nome do Cliente', contract.clientName),
                      _buildDetailRow('Vendedor', contract.sellerId),
                      _buildDetailRow('Tipo', contract.type),
                      _buildDetailRow(
                        'Valor',
                        'R\$${contract.amount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow('Status', contract.status),
                      _buildDetailRow(
                        'Data de Início',
                        _formatDate(contract.startDate),
                      ),
                      _buildDetailRow(
                        'Data de Término',
                        _formatDate(contract.endDate),
                      ),
                      _buildDetailRow(
                        'Data de Criação',
                        _formatDate(contract.createdAt),
                      ),
                      _buildDetailRow('Método de Pagamento', contract.paymentMethod),
                      _buildDetailRow(
                        'Parcelas',
                        '${contract.installments.toString()}x',
                      ),
                      _buildDetailRow('Tipo de Renovação', contract.renewalType),
                      _buildDetailRow('Origem de Vendas', contract.salesOrigin),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Volta para a página anterior
                          },
                          child: const Text('Voltar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para exibir uma linha de detalhe
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis, // Garante que o texto longo não estoure
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
