import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/repositories/lead_repository.dart';

class LeadFormPage extends StatefulWidget {
  @override
  _LeadFormPageState createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _nomeOportunidadeController = TextEditingController();
  final _sdrController = TextEditingController();
  final _vendedorController = TextEditingController();
  final _origemController = TextEditingController();
  final _linkController = TextEditingController();

  final LeadRepository _leadRepository = LeadRepository();

  bool _isLoading = false; // Controla o estado de carregamento

  Future<void> _addLead() async {
    try {
      setState(() {
        _isLoading = true; // Inicia o carregamento
      });

      String leadId = const Uuid().v4();

      LeadModel lead = LeadModel(
        leadId: leadId,
        name: _nomeOportunidadeController.text.trim(),
        vendedor: _vendedorController.text.trim(),
        link: _linkController.text.trim(),
        origem: _origemController.text.trim(),
      );

      await _leadRepository.addLead(lead);

      Get.snackbar(
        'Sucesso',
        'Lead cadastrado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/home'); // Redireciona para a HomePage
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao cadastrar lead: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false; // Finaliza o carregamento
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
            if (_isLoading) // Mostra o indicador de carregamento
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
                      controller: _origemController,
                      decoration: const InputDecoration(
                        labelText: 'Origem (Inbound/Outbound)',
                      ),
                    ),
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link da Oportunidade',
                      ),
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
