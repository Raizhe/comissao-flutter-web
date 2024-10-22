import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/clients_model.dart';
import '../../../widgets/navbar_widget.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];
  bool _isAscending = true; // Controla a ordem de ordenação

  // Busca os clientes do Firestore
  Stream<List<ClientModel>> _fetchClients() {
    return FirebaseFirestore.instance.collection('clients').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        return ClientModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchClients().listen((clients) {
      setState(() {
        _clients = clients;
        _filteredClients = clients;
      });
    });
  }

  // Filtra clientes com base na pesquisa
  void _searchClients(String query) {
    setState(() {
      _filteredClients = _clients.where((client) {
        return client.clientName.toLowerCase().contains(query.toLowerCase()) ||
            client.companyName.toLowerCase().contains(query.toLowerCase()) ||
            (client.phone?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            client.situation.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Ordena os clientes de forma crescente ou decrescente
  void _sortClients() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredClients.sort((a, b) {
        return _isAscending
            ? a.clientName.compareTo(b.clientName)
            : b.clientName.compareTo(a.clientName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de pesquisa no topo
                NavbarWidget(
                  hintText: 'Buscar por nome, empresa, telefone ou situação',
                  onSearch: _searchClients,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildClientTable(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cria uma tabela para exibir os clientes
  Widget _buildClientTable() {
    if (_filteredClients.isEmpty) {
      return const Center(
        child: Text('Nenhum cliente encontrado.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 60,
        columns: [
          const DataColumn(label: Text('Nome')),
          const DataColumn(label: Text('Empresa')),
          const DataColumn(label: Text('Telefone')),
          const DataColumn(label: Text('Situação')),
          DataColumn(
            label: Row(
              children: [
                const Text('Ações'),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort), // Ícone de filtro
                  onSelected: (value) {
                    if (value == 'A-Z') {
                      _sortClientsAscending();
                    } else if (value == 'Z-A') {
                      _sortClientsDescending();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'A-Z',
                      child: Text('Classificar de A-Z'),
                    ),
                    const PopupMenuItem(
                      value: 'Z-A',
                      child: Text('Classificar de Z-A'),
                    ),
                  ],
                ),
              ],
            ),
          ),


        ],
        rows: _filteredClients.map((client) {
          return DataRow(
            cells: [
              DataCell(
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/client_details', arguments: client);
                  },
                  child: Text(
                    client.clientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              DataCell(Text(client.companyName)),
              DataCell(Text(client.phone ?? 'Não disponível')),
              DataCell(Text(client.situation)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Get.toNamed('/client_form', arguments: client);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  void _sortClientsAscending() {
    setState(() {
      _filteredClients.sort((a, b) => a.clientName.compareTo(b.clientName));
    });
  }

  void _sortClientsDescending() {
    setState(() {
      _filteredClients.sort((a, b) => b.clientName.compareTo(a.clientName));
    });
  }

}
