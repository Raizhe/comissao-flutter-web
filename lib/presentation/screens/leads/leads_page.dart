import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/lead_model.dart';
import '../../../widgets/navbar_widget.dart';

class LeadPage extends StatefulWidget {
  const LeadPage({Key? key}) : super(key: key);

  @override
  _LeadPageState createState() => _LeadPageState();
}

class _LeadPageState extends State<LeadPage> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filteredLeads = [];

  Stream<List<LeadModel>> _fetchLeads() {
    return FirebaseFirestore.instance.collection('leads').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        return LeadModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList(),
    );
  }

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

  void _searchLeads(String query) {
    setState(() {
      _filteredLeads = _leads.where((lead) {
        return lead.name.toLowerCase().contains(query.toLowerCase()) ||
            lead.vendedor.toLowerCase().contains(query.toLowerCase()) ||
            lead.sdr.toLowerCase().contains(query.toLowerCase()) ||
            lead.origem.toLowerCase().contains(query.toLowerCase());
      }).toList();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navbar com alinhamento igual à tabela
                NavbarWidget(
                  hintText: 'Buscar por nome, vendedor, SDR, ou origem',
                  onSearch: _searchLeads,
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
          DataColumn(label: Text('SDR')),
          DataColumn(label: Text('Vendedor')),
          DataColumn(label: Text('Origem')),
          DataColumn(label: Text('Link')),
        ],
        rows: _filteredLeads.map((lead) {
          return DataRow(
            cells: [
              DataCell(Text(lead.name)),
              DataCell(Text(lead.sdr)),
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
