import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Importar o pacote para máscaras
import '../../../data/models/lead_model.dart';
import '../../../data/models/meet_model.dart';
import '../../../data/repositories/lead_repository.dart';
import '../../../data/repositories/meet_repository.dart';

class MeetFormPage extends StatefulWidget {
  @override
  _MeetFormPageState createState() => _MeetFormPageState();
}

class _MeetFormPageState extends State<MeetFormPage> {
  final _meetRepository = MeetRepository();
  final _leadRepository = LeadRepository();

  String? _selectedLeadId;
  List<LeadModel> _leads = [];

  // Controladores com máscara para os campos de data
  final _dataAgendamentoController = MaskedTextController(mask: '0000-00-00');
  final _dataMeetController = MaskedTextController(mask: '0000-00-00');

  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLeads(); // Carregar os leads disponíveis
  }

  Future<void> _fetchLeads() async {
    List<LeadModel> leads = await _leadRepository.getAllLeads();
    setState(() {
      _leads = leads;
    });
  }

  Future<void> _addMeet() async {
    try {
      String meetId = DateTime.now().millisecondsSinceEpoch.toString();

      MeetModel meet = MeetModel(
        meetId: meetId,
        leadId: _selectedLeadId!,
        dataAgendamento: DateTime.parse(_dataAgendamentoController.text),
        dataMeet: DateTime.tryParse(_dataMeetController.text),
        status: _statusController.text.trim(),
      );

      await _meetRepository.addMeet(meet);
      Get.back(); // Voltar para a página anterior após o cadastro
      Get.snackbar('Sucesso', 'Reunião cadastrada com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar reunião: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Reunião'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown para selecionar um Lead
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Lead'),
                items: _leads.map((lead) {
                  return DropdownMenuItem<String>(
                    value: lead.leadId,
                    child: Text(lead.name), // Exibe o nome da oportunidade
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLeadId = value;
                  });
                },
                value: _selectedLeadId,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dataAgendamentoController,
                decoration: const InputDecoration(
                    labelText: 'Data de Agendamento (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _dataMeetController,
                decoration: const InputDecoration(
                    labelText: 'Data da Reunião (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _statusController,
                decoration:
                const InputDecoration(labelText: 'Status (Sim/Não/Remarcada)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addMeet,
                child: const Text('Cadastrar Reunião'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
