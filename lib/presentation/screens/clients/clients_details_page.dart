import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/clients_model.dart';

class ClientDetailsPage extends StatelessWidget {
  final ClientModel client;

  ClientDetailsPage({Key? key})
      : client = Get.arguments ?? ClientModel.empty(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente: ${client.clientName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Empresa', client.companyName),
                    _buildDetailRow('Telefone', client.phone ?? 'Não disponível'),
                    _buildDetailRow('Situação', client.situation),
                    _buildDetailRow('Nome do Cliente', client.clientName,),

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
          Text(value),
        ],
      ),
    );
  }
}
