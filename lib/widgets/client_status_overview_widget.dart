import 'package:flutter/material.dart';

class ClientStatusOverviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> clientData;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  ClientStatusOverviewWidget({required this.clientData});

  Color getStatusColor(String status) {
    switch (status) {
      case 'ATIVO':
        return Colors.blue;
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
      case 'RENOVAÇÃO AUTOMATICA':
        return Colors.purple[200]!;
      case 'UPSELL':
        return Colors.green;
      default:
        return Colors.black; // Default color for undefined statuses
    }
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
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Cliente')),
                    DataColumn(label: Text('Janeiro')),
                    DataColumn(label: Text('Fevereiro')),
                    DataColumn(label: Text('Março')),
                    DataColumn(label: Text('Abril')),
                    DataColumn(label: Text('Maio')),
                    DataColumn(label: Text('Junho')),
                    DataColumn(label: Text('Julho')),
                    DataColumn(label: Text('Agosto')),
                    DataColumn(label: Text('Setembro')),
                    DataColumn(label: Text('Outubro')),
                    DataColumn(label: Text('Novembro')),
                    DataColumn(label: Text('Dezembro')),
                  ],
                  rows: clientData.map((client) {
                    // Buscando o status do contrato associado ao cliente
                    final String status = client['contract'] != null ? client['contract']['status'] ?? 'INDEFINIDO' : 'INDEFINIDO';
                    return DataRow(cells: [
                      DataCell(Text(client['nome'] ?? 'Nome não disponível')),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                      DataCell(Container(
                        color: getStatusColor(status),
                        child: Center(child: Text(status)),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
