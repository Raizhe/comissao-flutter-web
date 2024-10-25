import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/meet_model.dart';
import '../../../data/repositories/meet_repository.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({Key? key}) : super(key: key);

  @override
  _MeetPageState createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  final MeetRepository _meetRepository = MeetRepository();
  List<MeetModel> _meets = [];
  List<MeetModel> _filteredMeets = [];
  bool _isAscending = true; // Controle da ordem de classificação

  @override
  void initState() {
    super.initState();
    _fetchMeets();
  }

  Future<void> _fetchMeets() async {
    final meets = await _meetRepository.getAllMeets();
    setState(() {
      _meets = meets;
      _filteredMeets = meets;
    });
  }

  // Função para ordenar a lista de reuniões
  void _sortMeets() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredMeets.sort((a, b) =>
      _isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reuniões Agendadas'),
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
                              hintText: 'Buscar por ID, Lead ou Status',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (query) {
                              setState(() {
                                _filteredMeets = _meets.where((meet) {
                                  return meet.name
                                      .toLowerCase()
                                      .contains(query.toLowerCase()) ||
                                      meet.status
                                          .toLowerCase()
                                          .contains(query.toLowerCase());
                                }).toList();
                              });
                            },
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
                            _sortMeets();
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
                      child: _buildAdaptiveMeetTable(context),
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

  Widget _buildAdaptiveMeetTable(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
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
          const DataColumn(label: Text('Data Agendamento')),
          if (!isCompact) const DataColumn(label: Text('Data da Reunião')),
          const DataColumn(label: Text('Status')),
        ],
        rows: _filteredMeets.map((meet) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  meet.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              DataCell(Text(_formatDate(meet.dataAgendamento))),
              if (!isCompact) DataCell(Text(_formatDate(meet.dataMeet))),
              DataCell(
                Text(
                  meet.status,
                  style: TextStyle(
                    color: _getStatusColor(meet.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
