import 'package:comissao_flutter_web/presentation/screens/clients/clients_details_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/clients_model.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];
  bool _isAscending = true;

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

  Stream<List<ClientModel>> _fetchClients() {
    return FirebaseFirestore.instance.collection('clients').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        return ClientModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList(),
    );
  }

  void _searchClients(String query) {
    setState(() {
      _filteredClients = _clients.where((client) {
        return client.nome.toLowerCase().contains(query.toLowerCase()) ||
            (client.cpfcnpj?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            (client.telefone?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            client.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _sortClients() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredClients.sort((a, b) {
        return _isAscending
            ? a.nome.compareTo(b.nome)
            : b.nome.compareTo(a.nome);
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
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Buscar por nome, CNPJ/CPF, telefone ou situação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: _searchClients,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (value) {
                            if (value == 'A-Z') {
                              setState(() => _isAscending = true);
                            } else {
                              setState(() => _isAscending = false);
                            }
                            _sortClients();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'A-Z',
                              child: Text('Ordenar A-Z'),
                            ),
                            const PopupMenuItem(
                              value: 'Z-A',
                              child: Text('Ordenar Z-A'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildAdaptiveClientTable(constraints.maxWidth);
                        },
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

  Widget _buildAdaptiveClientTable(double maxWidth) {
    final isCompact = maxWidth < 600;

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: isCompact ? 20 : 50,
        headingRowHeight: 40,
        border: TableBorder(
          verticalInside: BorderSide(
            width: 1,
            color: Colors.grey.shade300,
          ),
        ),
        columns: [
          const DataColumn(label: Text('Nome')),
          if (!isCompact) const DataColumn(label: Text('CNPJ/CPF')),
          if (!isCompact) const DataColumn(label: Text('Telefone')),
          if (!isCompact) const DataColumn(label: Text('Cidade')),
          const DataColumn(label: Text('Situação')),
          const DataColumn(label: Text('Ações')),
        ],
        rows: _filteredClients.map((client) {
          return DataRow(
            cells: [
              _buildHoverableClientNameCell(client),
              if (!isCompact) DataCell(Text(client.cpfcnpj ?? 'Não disponível')),
              if (!isCompact) DataCell(Text(client.telefone ?? 'Não disponível')),
              if (!isCompact) DataCell(Text(client.cidade ?? 'Não disponível')),
              DataCell(Text(client.status)),
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

  DataCell _buildHoverableClientNameCell(ClientModel client) {
    bool isHovered = false;

    return DataCell(
      StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: () {
                Get.toNamed('/client_details', arguments: client);
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
                child: Text(client.nome),
              ),
            ),
          );
        },
      ),
    );
  }
}
