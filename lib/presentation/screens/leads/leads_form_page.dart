import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/meet_model.dart';
import '../../../data/repositories/lead_repository.dart';
import '../../../data/repositories/meet_repository.dart';

class LeadFormPage extends StatefulWidget {
  const LeadFormPage({Key? key}) : super(key: key);

  @override
  State<LeadFormPage> createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _nomeOportunidadeController = TextEditingController();
  final _linkController = TextEditingController();
  final _leadRepository = LeadRepository();
  final _meetRepository = MeetRepository();
  String? _origem;
  String? _selectedSeller;
  DateTime? _dataReuniao;
  TimeOfDay? _horaReuniao;

  Future<void> _addLead() async {
    if (_origem == null || _dataReuniao == null || _horaReuniao == null || _selectedSeller == null) {
      Get.snackbar(
        'Erro',
        'Por favor, preencha todos os campos obrigatórios.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      String leadId = const Uuid().v4();
      String meetId = const Uuid().v4();
      final DateTime dataHoraReuniao = DateTime(
        _dataReuniao!.year,
        _dataReuniao!.month,
        _dataReuniao!.day,
        _horaReuniao!.hour,
        _horaReuniao!.minute,
      );

      LeadModel lead = LeadModel(
        leadId: leadId,
        name: _nomeOportunidadeController.text.trim(),
        vendedor: _selectedSeller!,
        link: _linkController.text.trim(),
        origem: _origem!,
      );

      await _leadRepository.addLead(lead);
      await _meetRepository.addMeet(
        MeetModel(
          name: lead.name,
          meetId: meetId,
          leadId: leadId,
          dataAgendamento: DateTime.now(),
          dataMeet: dataHoraReuniao,
          status: 'Pendente',
        ),
      );

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
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dataReuniao = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _horaReuniao = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Lead'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600,
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cadastro de Lead',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormGrid(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: _addLead,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      children: [
        _buildTextField(_nomeOportunidadeController, 'Nome da Oportunidade'),
        _buildTextField(_linkController, 'Link da Oportunidade'),
        _buildDropdownButtonFormField(
          'Origem',
          ['Inbound', 'Outbound'],
              (value) => _origem = value,
        ),
        _buildDropdownButtonFormField(
          'Vendedor',
          ['Vendedor 1', 'Vendedor 2'],
              (value) => _selectedSeller = value,
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(
            _dataReuniao == null
                ? 'Selecione a Data da Reunião'
                : 'Data: ${_dataReuniao!.day}/${_dataReuniao!.month}/${_dataReuniao!.year}',
          ),
          onTap: () => _selectDate(context),
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(
            _horaReuniao == null
                ? 'Selecione a Hora da Reunião'
                : 'Hora: ${_horaReuniao!.format(context)}',
          ),
          onTap: () => _selectTime(context),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
