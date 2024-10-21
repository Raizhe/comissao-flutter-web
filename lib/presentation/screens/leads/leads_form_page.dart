import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  String? _selectedSeller;
  DateTime? _dataReuniao;
  TimeOfDay? _horaReuniao;

  final LeadRepository _leadRepository = LeadRepository();
  final MeetRepository _meetRepository = MeetRepository();
  bool _isLoading = false;

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
        sdr: 'SDR1',
        vendedor: _selectedSeller!,
        link: _linkController.text.trim(),
        origem: _origem!,
      );

      MeetModel meet = MeetModel(
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

  Future<List<SellerModel>> _fetchSellers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('sellers').get();
    return snapshot.docs.map((doc) => SellerModel.fromFirestore(doc)).toList();
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
      appBar: AppBar(title: const Text('Cadastrar Lead')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 500, // Definição de largura do cartão
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
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
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          TextField(
                            controller: _nomeOportunidadeController,
                            decoration: const InputDecoration(
                              labelText: 'Nome da Oportunidade',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          FutureBuilder<List<SellerModel>>(
                            future: _fetchSellers(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text('Erro ao carregar vendedores');
                              } else {
                                final sellers = snapshot.data!;
                                return DropdownButtonFormField<String>(
                                  value: _selectedSeller,
                                  decoration: const InputDecoration(
                                    labelText: 'Vendedor',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: sellers.map((seller) {
                                    return DropdownMenuItem(
                                      value: seller.name,
                                      child: Text(seller.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedSeller = value);
                                  },
                                );
                              }
                            },
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
                            decoration: const InputDecoration(
                              labelText: 'Origem',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Inbound', 'Outbound'].map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _origem = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _addLead,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cadastrar Lead'),
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
}
