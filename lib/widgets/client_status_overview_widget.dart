import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClientStatusOverviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> clientData;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  ClientStatusOverviewWidget({required this.clientData});

  // Método para obter a cor do status do cliente
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

  // Método para obter o status de um cliente para um determinado mês
  String getMonthlyStatus(Map<String, dynamic> client, int month) {
    // Ensure registeredAt is a DateTime
    DateTime registeredAt;
    if (client['registeredAt'] is Timestamp) {
      registeredAt = (client['registeredAt'] as Timestamp).toDate(); // Convert from Timestamp to DateTime
    } else if (client['registeredAt'] is DateTime) {
      registeredAt = client['registeredAt'];
    } else {
      // Default fallback if registeredAt is null or an invalid type
      return 'INDEFINIDO';
    }

    String status = client['status'];

    // Verifica se o cliente foi registrado antes ou durante o mês atual
    if (registeredAt.month <= month && registeredAt.year <= DateTime.now().year) {
      return status; // Retorna o status do cliente
    }
    return 'INDEFINIDO'; // Caso o cliente não tenha sido registrado ainda
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8.0,
      margin: const EdgeInsets.all(25.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna fixa com os clientes
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {0: FixedColumnWidth(200.0)},
                  children: [
                    // Cabeçalho Cliente
                    TableRow(
                      children: [
                        Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: const Text(
                            'Cliente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Lista de Clientes
                    ...clientData.map((client) {
                      return TableRow(
                        children: [
                          Container(
                            height: 60,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              client['nome'] ?? 'Nome não disponível',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                // Scroll horizontal para os meses
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {
                          for (int i = 0; i < 12; i++) i: const FixedColumnWidth(120.0),
                        },
                        children: [
                          // Cabeçalho dos Meses
                          TableRow(
                            children: [
                              'Janeiro',
                              'Fevereiro',
                              'Março',
                              'Abril',
                              'Maio',
                              'Junho',
                              'Julho',
                              'Agosto',
                              'Setembro',
                              'Outubro',
                              'Novembro',
                              'Dezembro',
                            ].map((month) {
                              return Container(
                                height: 60,
                                alignment: Alignment.center,
                                child: Text(
                                  month,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // Linhas de Status por Cliente
                          ...clientData.map((client) {
                            return TableRow(
                              children: [
                                for (int month = 1; month <= 12; month++)
                                  Container(
                                    height: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: getStatusColor(getMonthlyStatus(client, month)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      getMonthlyStatus(client, month),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
