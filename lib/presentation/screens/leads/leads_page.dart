import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/lead_model.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({Key? key}) : super(key: key);

  @override
  _LeadsPageState createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filteredLeads = [];
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchLeads().listen((leads) {
      setState(() {
        _leads = leads;
        _filteredLeads = leads;
      });
    });
  }

  Stream<List<LeadModel>> _fetchLeads() {
    return FirebaseFirestore.instance.collection('leads').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        return LeadModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList(),
    );
  }

  void _searchLeads(String query) {
    setState(() {
      _filteredLeads = _leads.where((lead) {
        return lead.name.toLowerCase().contains(query.toLowerCase()) ||
            lead.vendedor.toLowerCase().contains(query.toLowerCase()) ||
            lead.origem.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _sortLeads() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredLeads.sort((a, b) {
        return _isAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
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
                              hintText: 'Buscar por nome, vendedor ou origem',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: _searchLeads,
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
                            _sortLeads();
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
                      child: _buildLeadTable(),
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

  Widget _buildLeadTable() {
    if (_filteredLeads.isEmpty) {
      return const Center(
        child: Text('Nenhum lead encontrado.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 60,
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('Vendedor')),
          DataColumn(label: Text('Origem')),
          DataColumn(label: Text('Link')),
        ],
        rows: _filteredLeads.map((lead) {
          return DataRow(
            cells: [
              DataCell(Text(lead.name)),
              DataCell(Text(lead.vendedor)),
              DataCell(Text(lead.origem)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _openLink(lead.link),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o link: $url';
    }
  }
}
