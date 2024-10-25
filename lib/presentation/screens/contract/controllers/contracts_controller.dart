import 'package:comissao_flutter_web/data/models/contract_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/repositories/contract_repository.dart';

class ContractController extends GetxController {
  final ContractRepository _contractRepository = ContractRepository();

  // Variáveis reativas para armazenar contratos e status de carregamento
  var contracts = <ContractModel>[].obs;
  var filteredContracts = <ContractModel>[].obs; // Contratos filtrados
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContracts(); // Busca inicial de contratos ao iniciar
  }

  // Método para adicionar um contrato
  Future<void> addContract(ContractModel contract) async {
    isLoading.value = true;
    try {
      await _contractRepository.addContract(contract);
      contracts.add(contract);
      filteredContracts.add(contract); // Adiciona também à lista filtrada
      Get.snackbar('Sucesso', 'Contrato cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar contrato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para buscar todos os contratos
  Future<void> fetchContracts() async {
    isLoading.value = true;
    try {
      List<ContractModel> fetchedContracts =
      await _contractRepository.getAllContracts();
      contracts.assignAll(fetchedContracts);
      filteredContracts.assignAll(fetchedContracts); // Preenche a lista filtrada
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar contratos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método de pesquisa para filtrar contratos por nome, tipo ou status
  void searchContracts(String query) {
    if (query.isEmpty) {
      filteredContracts.assignAll(contracts);
    } else {
      final results = contracts.where((contract) {
        return contract.clientName.toLowerCase().contains(query.toLowerCase()) ||
            contract.type.toLowerCase().contains(query.toLowerCase()) ||
            contract.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
      filteredContracts.assignAll(results);
    }
  }

  // Método para deletar um contrato
  Future<void> deleteContract(String contractId) async {
    isLoading.value = true;
    try {
      await _contractRepository.deleteContract(contractId);
      contracts.removeWhere((contract) => contract.contractId == contractId);
      filteredContracts.removeWhere((contract) => contract.contractId == contractId);
      Get.snackbar('Sucesso', 'Contrato excluído com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao excluir contrato: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
