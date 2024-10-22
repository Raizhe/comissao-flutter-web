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

  final _formKey = GlobalKey<FormState>();

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
          'uid': doc.id,
          'name': data['name']?.toString() ?? 'Sem Nome',
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
          'cnpj': data['cnpj']?.toString() ?? 'Sem CNPJ',
          'name': data['name']?.toString() ?? 'Sem Nome',
        };
      }).toList();
    });
  }

  Future<void> _addContract() async {
    if (!_formKey.currentState!.validate()) {
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
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Contrato'),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Cadastro de Contrato',
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
                          onPressed: _addContract,
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
        _buildDropdownField(
          'CNPJ do Cliente',
          _selectedClientCNPJ,
          _clients,
              (value) {
            setState(() {
              _selectedClientCNPJ = value;
              _selectedClientName =
              _clients.firstWhere((client) => client['cnpj'] == value)['name'];
            });
          },
        ),
        _buildDropdownField('Vendedor', _selectedSellerId, _sellers, (value) {
          setState(() {
            _selectedSellerId = value;
          });
        }),
        _buildTextField(_typeController, 'Tipo de Contrato'),
        _buildTextField(_amountController, 'Valor', TextInputType.number),
        _buildTextField(_paymentMethodController, 'Forma de Pagamento'),
        _buildTextField(_installmentsController, 'Parcelas', TextInputType.number),
        _buildTextField(_renewalTypeController, 'Tipo de Renovação'),
        _buildTextField(_salesOriginController, 'Origem da Venda'),
      ],
    );
  }

  Widget _buildDropdownField(
      String label,
      String? value,
      List<Map<String, String>> items,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(label),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['uid'] ?? item['cnpj'],
          child: Text('${item['cnpj'] ?? ''} - ${item['name']}'),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, [TextInputType? type]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}
