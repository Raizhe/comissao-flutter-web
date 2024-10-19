import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Para formatar a data
import '../../../data/models/lead_model.dart';
import '../../../data/models/meet_model.dart';
import '../../../data/repositories/lead_repository.dart';
import '../../../data/repositories/meet_repository.dart';

class LeadFormPage extends StatefulWidget {
  @override
  _LeadFormPageState createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _nomeOportunidadeController = TextEditingController();
  final _vendedorController = TextEditingController();
  final _linkController = TextEditingController();
  String? _origem; // Armazena a origem selecionada (Inbound/Outbound)
  DateTime? _dataReuniao; // Armazena a data selecionada

  final LeadRepository _leadRepository = LeadRepository();
  final MeetRepository _meetRepository = MeetRepository();
  bool _isLoading = false; // Controla o estado de carregamento

  Future<void> _addLead() async {
    if (_origem == null || _dataReuniao == null) {
      Get.snackbar(
        'Erro',
        'Por favor, preencha todos os campos obrigatórios.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      String leadId = const Uuid().v4();
      String meetId = const Uuid().v4();

      // Criação do Lead
      LeadModel lead = LeadModel(
        leadId: leadId,
        name: _nomeOportunidadeController.text.trim(),
        sdr: 'SDR1', // Pode ser dinâmico se necessário
        vendedor: _vendedorController.text.trim(),
        link: _linkController.text.trim(),
        origem: _origem!,
      );

      // Criação da Reunião associada
      MeetModel meet = MeetModel(
        meetId: meetId,
        leadId: leadId,
        dataAgendamento: DateTime.now(),
        dataMeet: _dataReuniao!,
        status: 'Pendente',
      );

      await _leadRepository.addLead(lead);
      await _meetRepository.addMeet(meet);

      Get.snackbar(
        'Sucesso',
        'Lead e reunião cadastrados com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao cadastrar lead e reunião: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Abre o seletor de datas
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dataReuniao) {
      setState(() {
        _dataReuniao = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Lead')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: _nomeOportunidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Oportunidade',
                      ),
                    ),
                    TextField(
                      controller: _vendedorController,
                      decoration: const InputDecoration(
                        labelText: 'Vendedor',
                      ),
                    ),
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link da Oportunidade',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown para selecionar a origem
                    DropdownButtonFormField<String>(
                      value: _origem,
                      decoration: const InputDecoration(
                        labelText: 'Origem',
                      ),
                      items: ['Inbound', 'Outbound']
                          .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _origem = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Botão para selecionar a data da reunião
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(_dataReuniao == null
                          ? 'Selecione a Data da Reunião'
                          : 'Data: ${DateFormat('dd/MM/yyyy').format(_dataReuniao!)}'),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addLead,
                      child: const Text('Cadastrar Lead'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
