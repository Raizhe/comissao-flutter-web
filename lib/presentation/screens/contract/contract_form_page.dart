import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../data/models/clients_model.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/models/pre_seller_model.dart';
import '../../../data/models/seller_model.dart';
import 'controllers/contracts_controller.dart';

class ContractFormPage extends StatefulWidget {
  const ContractFormPage({super.key});

  @override
  _ContractFormPageState createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos
  final _customerSuccessController = TextEditingController(); // Sucesso do Cliente
  DateTime? _endDate;
  String? _renewalType;
  String? _salesOrigin;
  final _razaoSocialController = TextEditingController();
  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _cepController = MaskedTextController(mask: '00000-000');
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _telefoneController = MaskedTextController(mask: '(00) 0000-0000');
  final _emailFinanceiroController = TextEditingController();
  final _representanteController = TextEditingController();
  final _cpfRepresentanteController = MaskedTextController(mask: '000.000.000-00');
  final _valorController = MoneyMaskedTextController(
    initialValue: 0.0,
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    precision: 2,
  );
  final _parcelasController = TextEditingController();
  final _feeMensalController = TextEditingController();
  final _observacoesController = TextEditingController();

  double percentualMeta = 100.0;
  String type = 'MRR';

  // Variáveis para o tipo de contrato e forma de pagamento
  String? _tipoContrato;
  String? _formaPagamento;
  String? _selectedSellerId;
  String? _selectedPreSellerId;
  String? _selectedOperatorId;

  // Listas para armazenar dados do Firebase
  List<SellerModel> _sellers = [];
  List<PreSellerModel> _preSellers = [];
  List<OperatorModel> _operators = [];
  List<ClientModel> _clientes = [];

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _fetchSellers();
    _fetchPreSellers();
    _fetchOperators();
    Get.put(ContractController());
  }


  void _calculateFeeMensal() {
    final double valorTotal = _valorController.numberValue;
    final int parcelas = int.tryParse(_parcelasController.text) ?? 0;

    if (parcelas > 0) {
      final double feeMensal = valorTotal / parcelas;
      _feeMensalController.text = feeMensal.toStringAsFixed(2);
    } else {
      _feeMensalController.clear();
    }
  }
  // Função para buscar clientes e popular a lista de sugestões
  Future<void> _fetchClientes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('clients').get();
      setState(() {
        _clientes = snapshot.docs
            .map((doc) => ClientModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar clientes: $e');
    }
  }

  // Função para buscar vendedores
  Future<void> _fetchSellers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('sellers').get();
      setState(() {
        _sellers = snapshot.docs.map((doc) => SellerModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar vendedores: $e');
    }
  }

  // Função para buscar pré-vendedores
  Future<void> _fetchPreSellers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('pre_sellers').get();
      setState(() {
        _preSellers = snapshot.docs.map((doc) => PreSellerModel.fromMap(doc.data())).toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar pré-vendedores: $e');
    }
  }

  // Função para buscar operadores
  Future<void> _fetchOperators() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('operators').get();
      setState(() {
        _operators = snapshot.docs.map((doc) => OperatorModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar operadores: $e');
    }
  }

  // Função para preencher campos com dados do cliente selecionado
  void _preencherCamposCliente(ClientModel cliente) {
    _razaoSocialController.text = cliente.nome;
    _cnpjController.text = cliente.cpfcnpj;
    _logradouroController.text = cliente.rua ?? '';
    _numeroController.text = cliente.numero ?? '';
    _complementoController.text = cliente.complemento ?? '';
    _bairroController.text = cliente.bairro ?? '';
    _cidadeController.text = cliente.cidade ?? '';
    _estadoController.text = cliente.estado ?? '';
    _telefoneController.text = cliente.telefone ?? '';
    _emailFinanceiroController.text = cliente.email ?? '';
    _representanteController.text = cliente.nome;
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
            child: Column(
              children: [
                const SizedBox(height: 25),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 2.5,
                        ),
                        children: [
                          _buildAutoCompleteClienteField(),
                          _buildTextField(_razaoSocialController, 'Razão Social'),
                          _buildCepField(),
                          _buildTextField(_logradouroController, 'Logradouro'),
                          _buildTextField(_numeroController, 'Número', TextInputType.number),
                          _buildTextField(_complementoController, 'Complemento'),
                          _buildTextField(_bairroController, 'Bairro'),
                          _buildTextField(_cidadeController, 'Cidade'),
                          _buildTextField(_estadoController, 'Estado'),
                          _buildTelefoneField(),
                          _buildTextField(_emailFinanceiroController, 'E-mail Financeiro', TextInputType.emailAddress),
                          _buildTextField(_representanteController, 'Representante Legal'),
                          _buildTextField(_cpfRepresentanteController, 'CPF Representante'),
                          _buildTipoContratoDropdown(),
                          _buildTextField(_valorController, 'Valor', TextInputType.number),
                          _buildParcelasField(),
                          _buildFeeMensalField(),
                          _buildFormaPagamentoDropdown(),
                          _buildSellerDropdown(),
                          _buildPreSellerDropdown(),
                          _buildOperatorDropdown(),
                          _buildSalesOriginDropdown(),
                          _buildRenewalTypeDropdown(),
                          _buildEndDatePicker(),
                        ],
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Cadastrar Contrato'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeMensalField() {
    return TextFormField(
      controller: _feeMensalController,
      decoration: const InputDecoration(
        labelText: 'Fee Mensal',
        border: OutlineInputBorder(),
      ),
      readOnly: true, // This field is auto-calculated and should be read-only
    );
  }

  Widget _buildParcelasField() {
    return TextFormField(
      controller: _parcelasController,
      decoration: const InputDecoration(
        labelText: 'Parcelas',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => _calculateFeeMensal(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        final parcelas = int.tryParse(value);
        if (parcelas == null || parcelas <= 0) {
          return 'Número de parcelas inválido';
        }
        return null;
      },
    );
  }
  Widget _buildCepField() {
    return TextFormField(
      controller: _cepController,
      decoration: const InputDecoration(
        labelText: 'CEP',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.length == 9) { // Assuming 9 characters with format like '00000-000'
          final cepLimpo = value.replaceAll('-', '');
          _buscarEnderecoPorCep(cepLimpo); // Call with the valid postal code
        }
      },
      validator: (value) =>
      value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }


  Widget _buildAutoCompleteClienteField() {
    return Autocomplete<ClientModel>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<ClientModel>.empty();
        }
        return _clientes.where((cliente) {
          return cliente.cpfcnpj.contains(textEditingValue.text) ||
              cliente.nome.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (ClientModel cliente) => "${cliente.cpfcnpj} - ${cliente.nome}",
      onSelected: (ClientModel cliente) {
        _preencherCamposCliente(cliente);
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        fieldTextEditingController.text = _cnpjController.text;
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: const InputDecoration(
            labelText: 'CPF/CNPJ do Cliente',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
        );
      },
    );
  }

  // Função para buscar endereço pelo CEP
  Future<void> _buscarEnderecoPorCep(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == true) {
          Get.snackbar('Erro', 'CEP não encontrado');
        } else {
          setState(() {
            _logradouroController.text = data['logradouro'] ?? '';
            _bairroController.text = data['bairro'] ?? '';
            _cidadeController.text = data['localidade'] ?? '';
            _estadoController.text = data['uf'] ?? '';
          });
        }
      } else {
        Get.snackbar('Erro', 'Erro ao buscar CEP');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar CEP: $e');
    }
  }
  // Métodos de construção dos campos e dropdowns
  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType? type]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildTelefoneField() {
    return _buildTextField(
        _telefoneController, 'Telefone', TextInputType.phone);
  }

  Widget _buildTipoContratoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Tipo de Contrato'),
      items: ['Fee Mensal', 'Job'].map((tipo) {
        return DropdownMenuItem(value: tipo, child: Text(tipo));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _tipoContrato = value;
        });
      },
    );
  }

    Widget _buildValorField() {
    return TextFormField(
      controller: _valorController,
      decoration: const InputDecoration(
        labelText: 'Valor Total',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => _calculateFeeMensal(),
    );
  }

  // Widget _buildParcelasField() {
  //   return _buildTextField(
  //       _parcelasController, 'Parcelas', TextInputType.number);
  // }
  // //
  // Widget _buildFeeMensalField() {
  //   return TextFormField(
  //     controller: _feeMensalController,
  //     decoration: const InputDecoration(
  //       labelText: 'Fee Mensal',
  //       border: OutlineInputBorder(),
  //     ),
  //     readOnly: true,
  //   );
  // }

  Widget _buildFormaPagamentoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
      items: ['Crédito', 'Débito', 'Pix', 'Boleto'].map((method) {
        return DropdownMenuItem(value: method, child: Text(method));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formaPagamento = value;
        });
      },
    );
  }

  Widget _buildSellerDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Selecione o Vendedor'),
      value: _selectedSellerId,
      items: _sellers.map((seller) {
        return DropdownMenuItem(
          value: seller.sellerId,
          child: Text(seller.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSellerId = value;
        });
      },
      validator: (value) => value == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildPreSellerDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Selecione o Pré-Vendedor'),
      value: _selectedPreSellerId,
      items: _preSellers.map((preSeller) {
        return DropdownMenuItem(
          value: preSeller.preSellerId,
          child: Text(preSeller.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPreSellerId = value;
        });
      },
      validator: (value) => value == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildOperatorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Selecione o Operador'),
      value: _selectedOperatorId,
      items: _operators.map((operator) {
        return DropdownMenuItem(
          value: operator.operatorId,
          child: Text(operator.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedOperatorId = value;
        });
      },
      validator: (value) => value == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildSalesOriginDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Origem da Venda'),
      items: ['Inbound', 'Outbound'].map((origem) {
        return DropdownMenuItem(value: origem, child: Text(origem));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _salesOrigin = value;
        });
      },
    );
  }

  Widget _buildRenewalTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Tipo de Renovação'),
      items: ['Manual', 'Automático'].map((tipo) {
        return DropdownMenuItem(value: tipo, child: Text(tipo));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _renewalType = value;
        });
      },
    );
  }

  Widget _buildEndDatePicker() {
    return ListTile(
      title: Text(
        _endDate != null
            ? 'Data de Fim: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
            : 'Selecione a Data de Fim',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _endDate = picked;
          });
        }
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final double valorTotal = _valorController.numberValue;
        final int numeroParcelas = int.tryParse(_parcelasController.text) ?? 1;
        final double feeMensal = valorTotal / numeroParcelas;

        final double comissao = calculateCommission(
          feeMensal,
          _formaPagamento ?? 'Crédito',
          percentualMeta,
          numeroParcelas > 1,
        );

        final contract = ContractModel(
          contractId: Uuid().v4(),
          clientCNPJ: _cnpjController.text.trim(),
          clientName: _razaoSocialController.text.trim(),
          sellerId: _selectedSellerId!,
          operadorId: _selectedOperatorId,
          preSellerId: _selectedPreSellerId!,
          type: type,
          amount: valorTotal,
          startDate: DateTime.now(),
          endDate: null,
          status: 'ativo',
          createdAt: DateTime.now(),
          paymentMethod: _formaPagamento ?? 'Crédito',
          installments: numeroParcelas,
          renewalType: _renewalType ?? 'Manual',
          salesOrigin: _salesOrigin ?? 'Inbound',
          address: "${_logradouroController.text.trim()}, ${_numeroController.text.trim()}, ${_complementoController.text.trim()}, ${_bairroController.text.trim()}, ${_cidadeController.text.trim()} - ${_estadoController.text.trim()} - ${_cepController.text.trim()}",
          representanteLegal: _representanteController.text.trim(),
          cpfRepresentante: _cpfRepresentanteController.text.trim(),
          emailFinanceiro: _emailFinanceiroController.text.trim(),
          telefone: _telefoneController.text.trim(),
          observacoes: _observacoesController.text.trim(),
          feeMensal: feeMensal,
          costumerSuccess: 'Exemplo de Cs',
          commission: comissao,
        );

        await Get.find<ContractController>().addContract(contract);
        Get.snackbar('Sucesso', 'Contrato cadastrado com sucesso!');
        Get.offAllNamed('/home');
      } catch (e) {
        Get.snackbar('Erro', 'Erro ao cadastrar contrato: $e');
      }
    } else {
      Get.snackbar('Erro', 'Por favor, preencha todos os campos obrigatórios.');
    }
  }

  double calculateCommission(double feeMensal, String metodoPagamento,
      double percentualMeta, bool isParcelado) {
    final Map<String, Map<String, List<double>>> comissaoTabela = {
      'MRR': {
        'Cartão': [0.0, 0.16, 0.18, 0.20, 0.25],
        'BoletoPix': [0.0, 0.08, 0.10, 0.12, 0.16],
      },
      'Pontual': {
        'CartãoParcelado': [0.0, 0.12, 0.14, 0.16, 0.20],
        'CartãoAVista': [0.0, 0.06, 0.08, 0.10, 0.14],
        'BoletoPixParcelado': [0.0, 0.06, 0.08, 0.10, 0.14],
        'BoletoPixAVista': [0.0, 0.12, 0.14, 0.16, 0.20],
      }
    };

    int faixaMeta;
    if (percentualMeta < 50) {
      faixaMeta = 0;
    } else if (percentualMeta < 80) {
      faixaMeta = 1;
    } else if (percentualMeta < 100) {
      faixaMeta = 2;
    } else if (percentualMeta <= 120) {
      faixaMeta = 3;
    } else {
      faixaMeta = 4;
    }

    String chaveMetodo = metodoPagamento;
    if (type == 'Pontual') {
      if (metodoPagamento == 'Cartão') {
        chaveMetodo = isParcelado ? 'CartãoParcelado' : 'CartãoAVista';
      } else if (metodoPagamento == 'BoletoPix') {
        chaveMetodo = isParcelado ? 'BoletoPixParcelado' : 'BoletoPixAVista';
      }
    }

    if (comissaoTabela.containsKey(type) &&
        comissaoTabela[type]!.containsKey(chaveMetodo)) {
      final taxas = comissaoTabela[type]![chaveMetodo]!;
      final taxaComissao = taxas[faixaMeta];
      return feeMensal * taxaComissao;
    } else {
      return 0.0;
    }
  }
}
