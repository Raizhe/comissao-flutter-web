import 'package:flutter/material.dart';

class ClientStatusOverviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> clientData;

  const ClientStatusOverviewWidget({required this.clientData});

  Color getStatusColor(String status) {
    switch (status) {
      case 'ATIVO':
        return Colors.blue;
      case 'CANCELADO':
        return Colors.red;
      case 'INATIVO':
        return Colors.grey;
      case 'UPSELL':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Rolagem horizontal
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Rolagem vertical para a tabela
        child: DataTable(
          columns: [
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
            return DataRow(cells: [
              DataCell(Text(client['nome'] ?? 'Nome não disponível')),
              DataCell(Container(
                color: getStatusColor(client['janeiro'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['janeiro'] ?? 'Indefinido')),
              )),
              DataCell(Container(
                color: getStatusColor(client['fevereiro'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['fevereiro'] ?? 'Indefinido')),
              )),
              DataCell(Container(
                color: getStatusColor(client['março'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['março'] ?? 'Indefinido')),
              )),
              DataCell(Container(
                color: getStatusColor(client['abril'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['abril'] ?? 'Indefinido')),
              )),
              DataCell(Container(
                color: getStatusColor(client['maio'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['maio'] ?? 'Indefinido')),
              )),
              DataCell(Container(
                color: getStatusColor(client['junho'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['junho'] ?? 'Indefinido')),
              )),
              DataCell(Container(
                color: getStatusColor(client['julho'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['julho'] ?? 'Indefinido')),
              )), DataCell(Container(
                color: getStatusColor(client['Agosto'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['Agosto'] ?? 'Indefinido')),
              )), DataCell(Container(
                color: getStatusColor(client['Setembro'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['Setembro'] ?? 'Indefinido')),
              )), DataCell(Container(
                color: getStatusColor(client['Outubro'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['Outubro'] ?? 'Indefinido')),
              )), DataCell(Container(
                color: getStatusColor(client['Novembro'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['Novembro'] ?? 'Indefinido')),
              )), DataCell(Container(
                color: getStatusColor(client['Dezembro'] ?? 'INDEFINIDO'),
                child: Center(child: Text(client['Dezembro'] ?? 'Indefinido')),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
