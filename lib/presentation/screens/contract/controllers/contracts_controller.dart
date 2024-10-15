import 'package:comissao_flutter_web/data/models/contract_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/repositories/contract_repository.dart';


class ContractController extends GetxController {
  final ContractRepository _contractRepository = ContractRepository();

  // Variáveis reativas para armazenar contratos e status de carregamento
  var contracts = <ContractModel>[].obs;
  var isLoading = false.obs;

  // Método para adicionar um contrato
  Future<void> addContract(ContractModel contract) async {
    isLoading.value = true;
    try {
      await _contractRepository.addContract(contract);
      contracts.add(contract);
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
      List<ContractModel> fetchedContracts = await _contractRepository.getAllContracts();
      contracts.value = fetchedContracts;
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar contratos: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
