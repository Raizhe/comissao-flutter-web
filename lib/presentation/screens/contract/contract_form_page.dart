import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../data/models/contract_model.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/models/pre_seller_model.dart';
import '../../../data/models/seller_model.dart';
import '../../../data/repositories/pre_seller_repository.dart';
import 'controllers/contracts_controller.dart';

class ContractFormPage extends StatefulWidget {
  const ContractFormPage({Key? key}) : super(key: key);

  @override
  _ContractFormPageState createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  // Future<void> _buscarCep(String cep) async {
  //   try {
  //     final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       if (data.containsKey('erro') && data['erro'] == true) {
  //         Get.snackbar('Erro', 'CEP não encontrado.');
  //         return;
  //       }
  //
  //       setState(() {
  //         _logradouroController.text = data['logradouro'] ?? '';
  //         _bairroController.text = data['bairro'] ?? '';
  //         _cidadeController.text = data['localidade'] ?? '';
  //         _estadoController.text = data['uf'] ?? '';
  //       });
  //     } else {
  //       Get.snackbar('Erro', 'Erro ao buscar CEP.');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Erro', 'Erro ao buscar CEP: $e');
  //   }
  // }
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos
  final _customerSuccessController =
      TextEditingController(); // Sucesso do Cliente
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
  final _telefoneController = TextEditingController();
  final _emailFinanceiroController = TextEditingController();
  final _representanteController = TextEditingController();
  final _cpfRepresentanteController =
      MaskedTextController(mask: '000.000.000-00');
  final _valorController = MoneyMaskedTextController(
    initialValue: 0.0,
    // Valor inicial deve ser 0.0 para evitar erros
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    precision: 2, // Mantendo duas casas decimais
  );
  final _parcelasController = TextEditingController();
  final _feeMensalController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _tipoContrato;
  String? _formaPagamento;
  String? _selectedVendedorId;
  String? _selectedPreVendedorId;
  String? _selectedOperadorId;

  List<Map<String, dynamic>> _vendedores = [];
  List<Map<String, dynamic>> _preVendedores = [];
  List<Map<String, dynamic>> _operadores = [];
  List<SellerModel> _sellers = [];
  List<PreSellerModel> _preSellers = [];
  List<OperatorModel> _operators = [];

  String? _selectedSellerId;
  String? _selectedPreSellerId;
  String? _selectedOperatorId;

  @override
  void initState() {
    super.initState();
    _fetchSellers();
    _fetchPreSellers();
    _fetchOperators();
    Get.put(ContractController());
  }

// Função para buscar vendedores
  Future<void> _fetchSellers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('sellers').get();
      setState(() {
        _sellers =
            snapshot.docs.map((doc) => SellerModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar vendedores: $e');
    }
  }

// Função para buscar pré-vendedores
  Future<void> _fetchPreSellers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('pre_sellers').get();
      setState(() {
        _preSellers = snapshot.docs
            .map((doc) => PreSellerModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar pré-vendedores: $e');
    }
  }

// Função para buscar operadores
  Future<void> _fetchOperators() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('operators').get();
      setState(() {
        _operators = snapshot.docs
            .map((doc) => OperatorModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar operadores: $e');
    }
  }

  Future<void> _fetchDropdownData() async {
    final vendedores = await _fetchCollectionData('sellers');
    final preVendedores = await _fetchCollectionData('preSellers');
    final operadores = await _fetchCollectionData('operators');

    setState(() {
      _vendedores = vendedores;
      _preVendedores = preVendedores;
      _operadores = operadores;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchCollectionData(
      String collection) async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.docs.map((doc) {
      return {'uid': doc.id, 'name': doc['name'] ?? 'Sem Nome'};
    }).toList();
  }

  // Função para buscar endereço pelo CEP usando a API ViaCEP
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
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
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
                              crossAxisCount: 3, // 3 colunas
                              crossAxisSpacing: 16.0, // Espaço horizontal entre os campos
                              mainAxisSpacing: 16.0, // Espaço vertical entre os campos
                              childAspectRatio: 2.5, // Ajuste da proporção dos campos
                            ),
                            children: [
                              _buildTextField(_razaoSocialController, 'Razão Social'),
                              _buildTextField(_cnpjController, 'CNPJ', TextInputType.number),
                              _buildCepField(),
                              _buildTextField(_logradouroController, 'Logradouro'),
                              _buildTextField(_numeroController, 'Número', TextInputType.number),
                              _buildTextField(_complementoController, 'Complemento'),
                              _buildTextField(_bairroController, 'Bairro'),
                              _buildTextField(_cidadeController, 'Cidade'),
                              _buildTextField(_estadoController, 'Estado'),
                              _buildTextField(_telefoneController, 'Telefone', TextInputType.phone),
                              _buildTextField(_emailFinanceiroController, 'E-mail Financeiro', TextInputType.emailAddress),
                              _buildTextField(_representanteController, 'Representante Legal'),
                              _buildTextField(_cpfRepresentanteController, 'CPF Representante'),
                              _buildTipoContratoDropdown(),
                              _buildTextField(_valorController, 'Valor', TextInputType.number),
                              _buildParcelasField(),
                              _buildFeeMensalField(),
                              _buildFormaPagamentoDropdown(),
                              _buildSellerDropdown(), // Dropdown Vendedor
                              _buildPreSellerDropdown(), // Dropdown Pré-vendedor
                              _buildOperatorDropdown(), // Dropdown Operador
                              _buildSalesOriginDropdown(), // Origem da Venda
                              _buildRenewalTypeDropdown(), // Tipo de Renovação
                              _buildEndDatePicker(),
                            ],

                          ),

                        ),

                      ),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Cadastrar Contrato'),
                    ),// Data de Fim
                  ],
                );
              },
            ),
          ),
        ),
      ),
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


  Widget _buildSellerDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Selecione o Vendedor',
        border: OutlineInputBorder(),
      ),
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
      decoration: const InputDecoration(
        labelText: 'Selecione o Pré-Vendedor',
        border: OutlineInputBorder(),
      ),
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
      decoration: const InputDecoration(
        labelText: 'Selecione o Operador',
        border: OutlineInputBorder(),
      ),
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

  // Método para construir o campo de parcelas
  Widget _buildParcelasField() {
    return TextFormField(
      controller: _parcelasController,
      decoration: const InputDecoration(
        labelText: 'Parcelas',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _calcularFeeMensal(); // Chama a função para calcular o fee mensal automaticamente
      },
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

// Método para construir o campo de Fee Mensal (apenas leitura)
  Widget _buildFeeMensalField() {
    return TextFormField(
      controller: _feeMensalController,
      decoration: const InputDecoration(
        labelText: 'Fee Mensal',
        border: OutlineInputBorder(),
      ),
      readOnly: true, // O campo é apenas leitura, preenchido automaticamente
    );
  }

// Função para calcular o Fee Mensal com base no valor e no número de parcelas
  void _calcularFeeMensal() {
    final valor = _valorController.numberValue;
    final parcelas = int.tryParse(_parcelasController.text) ?? 1;

    if (parcelas > 0) {
      final feeMensal = valor / parcelas;
      _feeMensalController.text = feeMensal
          .toStringAsFixed(2); // Atualiza o campo com o valor calculado
    } else {
      _feeMensalController
          .clear(); // Limpa o campo se o número de parcelas for inválido
    }
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
        if (value.length == 9) {
          final cepLimpo = value.replaceAll('-', '');
          _buscarEnderecoPorCep(cepLimpo); // Remove o traço antes da consulta
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: selectedValue,
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['uid'] as String,
          child: Text(item['name'] as String),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
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

  Widget _buildFormaPagamentoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
      items: ['Crédito', 'Débito', 'Boleto'].map((method) {
        return DropdownMenuItem(value: method, child: Text(method));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formaPagamento = value;
        });
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType? type]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth, // Adapta ao espaço disponível
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
            value == null || value.isEmpty ? 'Campo obrigatório' : null,
          ),
        );
      },
    );
  }


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final double valorTotal = _valorController.numberValue;

        // Verificação se o valor é válido
        if (valorTotal <= 0) {
          Get.snackbar('Erro', 'O valor deve ser maior que zero.');
          return;
        }

        // Garantir que os IDs obrigatórios estão preenchidos
        if (_selectedSellerId == null) {
          Get.snackbar('Erro', 'Selecione um vendedor.');
          return;
        }
        if (_selectedSellerId == null) {
          Get.snackbar('Erro', 'Selecione um vendedor.');
          return;
        }
        if (_selectedPreSellerId == null) {
          Get.snackbar('Erro', 'Selecione um um pre vendedor.');
          return;
        }

        // Cálculo seguro do fee mensal
        final int numeroParcelas = int.tryParse(_parcelasController.text) ?? 1;
        final double feeMensal =
            numeroParcelas > 0 ? valorTotal / numeroParcelas : valorTotal;

        // Criação do contrato com dados válidos
        final contract = ContractModel(
          contractId: Uuid().v4(),
          clientCNPJ: _cnpjController.text.trim(),
          clientName: _razaoSocialController.text.trim(),
          address: "${_logradouroController.text.trim()}, "
              "${_numeroController.text.trim()}, "
              "${_complementoController.text.trim()}, "
              "${_bairroController.text.trim()}, "
              "${_cidadeController.text.trim()} - "
              "${_estadoController.text.trim()} - "
              "${_cepController.text.trim()}",
          telefone: _telefoneController.text.trim(),
          emailFinanceiro: _emailFinanceiroController.text.trim(),
          representanteLegal: _representanteController.text.trim(),
          cpfRepresentante: _cpfRepresentanteController.text.trim(),
          type: _tipoContrato ?? 'Fee Mensal',
          amount: valorTotal,
          installments: numeroParcelas,
          feeMensal: feeMensal,
          paymentMethod: _formaPagamento ?? 'Crédito',
          sellerId: _selectedSellerId!,
          preSellerId: _selectedPreSellerId!,
          operadorId: _selectedOperatorId,
          observacoes: _observacoesController.text.trim(),
          createdAt: DateTime.now(),
          status: 'ativo',
          startDate: DateTime.now(),
          endDate: null,
          renewalType: 'Manual',
          salesOrigin: 'Inbound',
          costumerSuccess: 'Exemplo de Cs',
        );

        // Tentativa de salvar no Firestore
        await Get.find<ContractController>().addContract(contract);

        Get.snackbar('Sucesso', 'Contrato cadastrado com sucesso!');
        Get.offAllNamed('/home'); // Redireciona para a home após sucesso
      } catch (e) {
        Get.snackbar('Erro', 'Erro ao cadastrar contrato: $e');
      }
    } else {
      Get.snackbar('Erro', 'Por favor, preencha todos os campos obrigatórios.');
    }
  }
}
