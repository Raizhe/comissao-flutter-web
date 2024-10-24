import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/contract_model.dart';
import 'controllers/contracts_controller.dart';

class ContractFormPage extends StatefulWidget {
  const ContractFormPage({Key? key}) : super(key: key);

  @override
  _ContractFormPageState createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _cpfController = MaskedTextController(mask: '000.000.000-00');
  final _typeController = TextEditingController();

  // Ajuste no controlador de valor para evitar erro de range
  final _amountController = MoneyMaskedTextController(
    initialValue: 0.0,  // Valor inicial válido
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _installmentsController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _renewalTypeController = TextEditingController();
  String? _selectedSalesOrigin = 'Inbound';
  String? _selectedSellerId;

  bool _showClientSuggestions = false;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _sellers = [];

  @override
  void initState() {
    super.initState();
    _fetchSellers();
    Get.put(ContractController());
  }

  Future<void> _fetchSellers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('sellers').get();

    setState(() {
      _sellers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'uid': doc.id, 'name': data['name'] ?? 'Sem Nome'};
      }).toList();
    });
  }

  Future<void> _searchClient(String query) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('clients')
        .where('cnpj', isEqualTo: query)
        .limit(1)
        .get();

    setState(() {
      _clients = snapshot.docs.map((doc) => doc.data()).toList();
      _showClientSuggestions = _clients.isNotEmpty;
    });
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
                        _buildSearchableCnpjField(),
                        const SizedBox(height: 16),
                        _buildSellerDropdown(),
                        const SizedBox(height: 16),
                        _buildSalesOriginDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(_typeController, 'Tipo de Contrato'),
                        const SizedBox(height: 16),
                        _buildCurrencyField(),
                        const SizedBox(height: 16),
                        _buildTextField(_installmentsController, 'Parcelas',
                            TextInputType.number),
                        const SizedBox(height: 16),
                        _buildPaymentMethodDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(_renewalTypeController, 'Tipo de Renovação'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final newContract = ContractModel(
                                contractId: const Uuid().v4(),
                                clientCNPJ: _cnpjController.text.trim(),
                                clientName: 'Nome do Cliente',
                                sellerId: _selectedSellerId!,
                                type: _typeController.text.trim(),
                                amount: _amountController.numberValue, // Correção aqui
                                startDate: DateTime.now(),
                                endDate: null,
                                status: 'ativo',
                                createdAt: DateTime.now(),
                                paymentMethod: _paymentMethodController.text.trim(),
                                installments: int.parse(
                                    _installmentsController.text.trim()),
                                renewalType: _renewalTypeController.text.trim(),
                                salesOrigin: _selectedSalesOrigin ?? 'Inbound',
                              );

                              try {
                                await Get.find<ContractController>().addContract(newContract);
                                Get.snackbar('Sucesso', 'Contrato cadastrado com sucesso!');
                                Get.offAllNamed('/home');
                              } catch (e) {
                                Get.snackbar('Erro', 'Erro ao cadastrar contrato: $e');
                              }
                            }
                          },
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

  Widget _buildSearchableCnpjField() {
    return Column(
      children: [
        TextFormField(
          controller: _cnpjController,
          decoration: const InputDecoration(
            labelText: 'CNPJ',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.replaceAll(RegExp(r'\D'), '').length == 14) {
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
            final clientCnpj = client['cnpj'] ?? '';

            return ListTile(
              title: Text(clientCnpj),
              onTap: () {
                setState(() {
                  _cnpjController.text = clientCnpj;
                  _cpfController.text = client['cpf'] ?? '';
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

  Widget _buildCurrencyField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Valor',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (_amountController.numberValue <= 0) {
          return 'Valor deve ser maior que zero';
        }
        return null;
      },
    );
  }

  // Método para o campo de seleção de vendedor
  Widget _buildSellerDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text('Selecione o Vendedor'),
      value: _selectedSellerId,
      items: _sellers.map((seller) {
        return DropdownMenuItem<String>(
          value: seller['uid'],
          child: Text(seller['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSellerId = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Vendedor',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

// Método para o campo de seleção da origem de venda
  Widget _buildSalesOriginDropdown() {
    const salesOrigins = ['Inbound', 'Outbound'];

    return DropdownButtonFormField<String>(
      value: _selectedSalesOrigin,
      items: salesOrigins.map((origin) {
        return DropdownMenuItem<String>(
          value: origin,
          child: Text(origin),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSalesOrigin = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Origem da Venda',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

// Método genérico para campos de texto
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

// Método para o campo de seleção de forma de pagamento
  Widget _buildPaymentMethodDropdown() {
    const paymentMethods = ['Crédito', 'Débito', 'Boleto'];

    return DropdownButtonFormField<String>(
      items: paymentMethods.map((method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (value) {
        _paymentMethodController.text = value!;
      },
      decoration: const InputDecoration(
        labelText: 'Forma de Pagamento',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

}
