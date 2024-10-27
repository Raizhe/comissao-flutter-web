import 'package:get/get.dart';
import '../../../../data/models/operator_model.dart';
import '../../../../data/repositories/operator_repository.dart';

class OperatorController extends GetxController {
  final OperatorRepository _operatorRepository = OperatorRepository();
  var operators = <OperatorModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOperators(); // Busca operadores ao inicializar
  }

  // Método para buscar operadores do banco
  Future<void> fetchOperators() async {
    isLoading.value = true;
    try {
      List<OperatorModel> fetchedOperators =
      await _operatorRepository.getAllOperators();
      operators.value = fetchedOperators;
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar operadores: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para adicionar operador ao banco
  Future<void> addOperator(OperatorModel operator) async {
    isLoading.value = true;
    try {
      await _operatorRepository.addOperator(operator);
      operators.add(operator); // Adiciona à lista local
      Get.snackbar('Sucesso', 'Operador cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar operador: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
