import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
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
  final _amountController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _paymentMethodController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _renewalTypeController = TextEditingController();
  final _salesOriginController = TextEditingController();

  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _cpfController = MaskedTextController(mask: '000.000.000-00');

  String? _selectedSellerId;
  String? _selectedClientName;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _sellers = [];
  bool _showClientSuggestions = false; // Controle da lista de sugestões

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('sellers').get();

    setState(() {
      _sellers = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _searchClient(String query) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('clients')
        .where('cnpj', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();

    setState(() {
      _clients = snapshot.docs.map((doc) => doc.data()).toList();
      _showClientSuggestions = _clients.isNotEmpty;
    });
  }

  Future<void> _addContract() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String contractId = const Uuid().v4();

      ContractModel newContract = ContractModel(
        contractId: contractId,
        clientCNPJ: _cnpjController.text,
        clientName: _selectedClientName!,
        sellerId: _selectedSellerId!,
        type: _typeController.text.trim(),
        amount: double.parse(
            _amountController.text.replaceAll(RegExp(r'[^\d.]'), '')),
        startDate: DateTime.now(),
        status: 'ativo',
        createdAt: DateTime.now(),
        paymentMethod: _paymentMethodController.text.trim(),
        installments: int.parse(_installmentsController.text.trim()),
        renewalType: _renewalTypeController.text.trim(),
        salesOrigin: _salesOriginController.text.trim(),
      );

      await _contractController.addContract(newContract);

      Get.snackbar('Sucesso', 'Contrato cadastrado com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar contrato: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildSearchableCnpjField() {
    return Column(
      children: [
        TextFormField(
          controller: _cnpjController,
          decoration: InputDecoration(
            labelText: 'CNPJ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onChanged: (value) {
            if (value.length >= 14) {
              _searchClient(value);
            } else {
              setState(() {
                _showClientSuggestions = false;
              });
            }
          },
          validator: (value) =>
          value == null || value.isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 10),
        _showClientSuggestions
            ? ListView.builder(
          shrinkWrap: true,
          itemCount: _clients.length,
          itemBuilder: (context, index) {
            final client = _clients[index];
            final clientName =
                client['name'] ?? 'Nome não disponível';
            final clientCnpj = client['cnpj'] ?? '';

            return ListTile(
              title: Text('$clientName - $clientCnpj'),
              onTap: () {
                setState(() {
                  _cnpjController.text = clientCnpj;
                  _cpfController.text = client['cpf'] ?? '';
                  _selectedClientName = clientName;
                  _showClientSuggestions = false;
                });
              },
            );
          },
        )
            : const SizedBox.shrink(),
      ],
    );
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
                    child: Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: [
                        _buildSearchableCnpjField(),
                        _buildTextField(_typeController, 'Tipo de Contrato'),
                        _buildCurrencyField(),
                        _buildTextField(_installmentsController, 'Parcelas',
                            TextInputType.number),
                        _buildPaymentMethodDropdown(),
                        _buildTextField(
                            _renewalTypeController, 'Tipo de Renovação'),
                        _buildTextField(
                            _salesOriginController, 'Origem da Venda'),
                        ElevatedButton(
                          onPressed: _addContract,
                          child: const Text('Cadastrar'),
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

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType? type]) {
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

  Widget _buildCurrencyField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Valor',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildPaymentMethodDropdown() {
    const paymentMethods = ['Crédito', 'Débito', 'Boleto'];

    return DropdownButtonFormField<String>(
      hint: const Text('Forma de Pagamento'),
      items: paymentMethods.map((method) {
        return DropdownMenuItem(value: method, child: Text(method));
      }).toList(),
      onChanged: (value) {
        _paymentMethodController.text = value!;
      },
      decoration: InputDecoration(
        labelText: 'Forma de Pagamento',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}
