import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/meet_model.dart';
import '../../../data/models/seller_model.dart';
import '../../../data/repositories/lead_repository.dart';
import '../../../data/repositories/meet_repository.dart';

class LeadFormPage extends StatefulWidget {
  const LeadFormPage({Key? key}) : super(key: key);

  @override
  _LeadFormPageState createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _nomeOportunidadeController = TextEditingController();
  final _linkController = TextEditingController();
  String? _origem;
  String? _selectedSeller; // Armazena o vendedor selecionado
  List<SellerModel> _sellers = [];
  DateTime? _dataReuniao;
  TimeOfDay? _horaReuniao;

  final LeadRepository _leadRepository = LeadRepository();
  final MeetRepository _meetRepository = MeetRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSellers(); // Carregar vendedores no início
  }

  Future<void> _fetchSellers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('sellers').get();
    setState(() {
      _sellers =
          snapshot.docs.map((doc) => SellerModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> _addLead() async {
    if (_nomeOportunidadeController.text.trim().isEmpty ||
        _selectedSeller == null ||
        _linkController.text.trim().isEmpty ||
        _origem == null ||
        _dataReuniao == null ||
        _horaReuniao == null) {
      Get.snackbar(
        'Erro',
        'Por favor, preencha todos os campos obrigatórios.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

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

      MeetModel meet = MeetModel(
        name: _nomeOportunidadeController.text.trim(),
        meetId: meetId,
        leadId: leadId,
        dataAgendamento: DateTime.now(),
        dataMeet: dataHoraReuniao,
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
    final TimeOfDay? picked = await showTimePicker(
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
      appBar: AppBar(title: const Text('Cadastrar Lead')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600, // Definição de largura do card
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
                      _buildFormGrid(), // Grade de campos do formulário
                      const SizedBox(height: 16),
                      _buildDateAndTimePickers(), // Campos de Data e Hora
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

// Função para construir o Grid com os campos de formulário
  Widget _buildFormGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dois campos por linha
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      children: [
        TextField(
          controller: _nomeOportunidadeController,
          decoration: const InputDecoration(
            labelText: 'Nome da Oportunidade',
            border: OutlineInputBorder(),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedSeller,
          hint: const Text('Selecione um vendedor'),
          items: _sellers.map((seller) {
            return DropdownMenuItem(
              value: seller.name,
              child: Text(seller.name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedSeller = value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: _linkController,
          decoration: const InputDecoration(
            labelText: 'Link da Oportunidade',
            border: OutlineInputBorder(),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _origem,
          hint: const Text('Origem'),
          items: ['Inbound', 'Outbound'].map((String value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => setState(() => _origem = value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(
            _dataReuniao == null
                ? 'Selecione a Data da Reunião'
                : 'Data: ${DateFormat('dd/MM/yyyy').format(_dataReuniao!)}',
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
}
