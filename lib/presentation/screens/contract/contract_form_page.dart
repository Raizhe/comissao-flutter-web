// lib/presentation/screens/contract/contract_form_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/contract_model.dart';
import '../contract/controllers/contracts_controller.dart';

class ContractFormPage extends StatefulWidget {
  const ContractFormPage({Key? key}) : super(key: key);

  @override
  _ContractFormPageState createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  final ContractController _contractController = Get.put(ContractController());

  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _renewalTypeController = TextEditingController();
  final _salesOriginController = TextEditingController();

  String? _selectedSellerId;
  String? _selectedClientCNPJ;
  String? _selectedClientName;

  List<Map<String, String>> _sellers = [];
  List<Map<String, String>> _clients = [];

  @override
  void initState() {
    super.initState();
    _fetchSellers();
    _fetchClientCNPJs();
  }
  Future<void> _fetchSellers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('sellers').get();

    setState(() {
      _sellers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id, // UID do vendedor
          'name': data['name']?.toString() ?? 'Sem Nome', // Nome como String
        };
      }).toList();
    });
  }

  Future<void> _fetchClientCNPJs() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('clients').get();

    setState(() {
      _clients = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'cnpj': data['cnpj']?.toString() ?? 'Sem CNPJ', // CNPJ como String
          'name': data['name']?.toString() ?? 'Sem Nome', // Nome como String
        };
      }).toList();
    });
  }



  Future<void> _addContract() async {
    if (_selectedSellerId == null || _selectedClientCNPJ == null) {
      Get.snackbar(
        'Erro',
        'Por favor, selecione um vendedor e um cliente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      String contractId = const Uuid().v4();

      ContractModel newContract = ContractModel(
        contractId: contractId,
        clientCNPJ: _selectedClientCNPJ!,
        clientName: _selectedClientName!,
        sellerId: _selectedSellerId!,
        type: _typeController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        startDate: DateTime.now(),
        endDate: null,
        status: 'ativo',
        createdAt: DateTime.now(),
        paymentMethod: _paymentMethodController.text.trim(),
        installments: int.parse(_installmentsController.text.trim()),
        renewalType: _renewalTypeController.text.trim(),
        salesOrigin: _salesOriginController.text.trim(),
      );

      await _contractController.addContract(newContract);

      Get.snackbar(
        'Sucesso',
        'Contrato cadastrado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao cadastrar contrato: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Contrato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedClientCNPJ,
                hint: const Text('Selecione o CNPJ do Cliente'),
                items: _clients.map((client) {
                  return DropdownMenuItem<String>(
                    value: client['cnpj'],
                    child: Text('${client['cnpj']} - ${client['name']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClientCNPJ = value;
                    _selectedClientName = _clients
                        .firstWhere((client) => client['cnpj'] == value)['name'];
                  });
                },
                decoration: const InputDecoration(labelText: 'CNPJ do Cliente'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSellerId,
                hint: const Text('Selecione o Vendedor'),
                items: _sellers.map((seller) {
                  return DropdownMenuItem<String>(
                    value: seller['uid'],
                    child: Text(seller['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSellerId = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Vendedor'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo de Contrato'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _paymentMethodController,
                decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
              ),
              TextField(
                controller: _installmentsController,
                decoration: const InputDecoration(labelText: 'Parcelas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _renewalTypeController,
                decoration: const InputDecoration(labelText: 'Tipo de Renovação'),
              ),
              TextField(
                controller: _salesOriginController,
                decoration: const InputDecoration(labelText: 'Origem da Venda'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addContract,
                child: const Text('Cadastrar Contrato'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
