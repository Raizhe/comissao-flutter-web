import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/clients_model.dart';
import '../../../widgets/success_dialog.dart';
import 'controllers/clients_controller.dart';

class ClientFormPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _cpfcnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final _inscricaoEstadualController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = MaskedTextController(mask: '(00) 0000-0000');
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = MaskedTextController(mask: '00000-000');
  final _paisController = TextEditingController();
  final _codigoProdutoController = TextEditingController();
  final _nomeProdutoController = TextEditingController();
  final _valorUnitarioController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _quantidadeController = TextEditingController();
  final _ncmController = TextEditingController();
  final _naturezaController = TextEditingController();
  final _codigoVendaController = TextEditingController();
  final _dataVendaController = TextEditingController();
  final _dataRetroativaController = TextEditingController();
  final _dataVencimentoPagamentoController = TextEditingController();

  final ClientsController _clientController = Get.put(ClientsController());

  // Função para buscar endereço pelo CEP
  Future<void> _searchAddressByCep(String cep) async {
    if (cep.isEmpty) return;
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          _ruaController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _cidadeController.text = data['localidade'] ?? '';
          _estadoController.text = data['uf'] ?? '';
        } else {
          Get.snackbar('Erro', 'CEP não encontrado');
        }
      } else {
        Get.snackbar('Erro', 'Erro ao buscar o CEP');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao buscar o endereço: $e');
    }
  }

  Future<void> _addClient() async {
    try {
      String clientId = const Uuid().v4();
      DateTime? dataVencimento = _dataVencimentoPagamentoController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_dataVencimentoPagamentoController.text)
          : null;

      ClientModel client = ClientModel(
        clientId: clientId,
        nome: _nameController.text.trim(),
        cpfcnpj: _cpfcnpjController.text.trim(),
        inscricaoEstadual: _inscricaoEstadualController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        rua: _ruaController.text.trim(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _estadoController.text.trim(),
        cep: _cepController.text.trim(),
        pais: _paisController.text.trim(),
        codigoProduto: int.tryParse(_codigoProdutoController.text.trim()),
        nomeProduto: _nomeProdutoController.text.trim(),
        valorUnitario: _valorUnitarioController.text.trim(),
        quantidade: int.tryParse(_quantidadeController.text.trim()) ?? 1,
        ncm: int.tryParse(_ncmController.text.trim()),
        natureza: int.tryParse(_naturezaController.text.trim()),
        codigoVenda: int.tryParse(_codigoVendaController.text.trim()),
        dataVenda: int.tryParse(_dataVendaController.text.trim()),
        dataRetroativa: int.tryParse(_dataRetroativaController.text.trim()),
        dataVencimentoPagamento: dataVencimento,
        contracts: [],
        registeredAt: DateTime.now(),
        situation: 'Ativo',
      );

      await _clientController.addClient(client);
      SuccessDialog.showSuccess('Cliente cadastrado com sucesso!');
      _clearFields();
      Get.offAllNamed('/home');
    } catch (e) {
      SuccessDialog.showError('Erro ao cadastrar cliente: $e');
    }
  }

  void _clearFields() {
    _nameController.clear();
    _cpfcnpjController.updateText('');
    _inscricaoEstadualController.clear();
    _emailController.clear();
    _telefoneController.updateText('');
    _ruaController.clear();
    _numeroController.clear();
    _complementoController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _estadoController.clear();
    _cepController.updateText('');
    _paisController.clear();
    _codigoProdutoController.clear();
    _nomeProdutoController.clear();
    _valorUnitarioController.updateValue(0);
    _quantidadeController.clear();
    _ncmController.clear();
    _naturezaController.clear();
    _codigoVendaController.clear();
    _dataVendaController.clear();
    _dataRetroativaController.clear();
    _dataVencimentoPagamentoController.clear();
  }

  // Função para selecionar data de vencimento usando o calendário
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
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
                        'Cadastro de Cliente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormGrid(context),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: _addClient,
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

  Widget _buildFormGrid(BuildContext context) {
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
        _buildTextField(_nameController, 'Nome do Cliente'),
        _buildTextField(_cpfcnpjController, 'CPF/CNPJ', TextInputType.number),
        _buildTextField(_inscricaoEstadualController, 'Inscrição Estadual'),
        _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
        _buildTextField(
            _cepController, 'CEP', TextInputType.number, _searchAddressByCep),
        _buildTextField(_telefoneController, 'Telefone', TextInputType.phone),
        _buildTextField(_ruaController, 'Rua'),
        _buildTextField(_numeroController, 'Número', TextInputType.number),
        _buildTextField(_complementoController, 'Complemento'),
        _buildTextField(_bairroController, 'Bairro'),
        _buildTextField(_cidadeController, 'Cidade'),
        _buildTextField(_estadoController, 'Estado'),
        _buildTextField(_paisController, 'País'),
        _buildTextField(_codigoProdutoController, 'Código do Produto',
            TextInputType.number),
        _buildTextField(_nomeProdutoController, 'Nome do Produto'),
        _buildTextField(
            _valorUnitarioController, 'Valor Unitário', TextInputType.number),
        _buildTextField(
            _quantidadeController, 'Quantidade', TextInputType.number),
        _buildTextField(_ncmController, 'NCM', TextInputType.number),
        _buildTextField(_naturezaController, 'Natureza', TextInputType.number),
        _buildTextField(
            _codigoVendaController, 'Código da Venda', TextInputType.number),
        GestureDetector(
          onTap: () => _selectDate(context, _dataVencimentoPagamentoController),
          child: AbsorbPointer(
            child: _buildTextField(
              _dataVencimentoPagamentoController,
              'Data de Vencimento',
              TextInputType.datetime,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, [
        TextInputType? type,
        void Function(String)? onChanged,
      ]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
