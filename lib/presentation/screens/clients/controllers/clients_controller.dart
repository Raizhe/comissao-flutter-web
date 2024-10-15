import 'package:get/get.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/repositories/client_repository.dart';


class ClientController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();

  // Variável observável para o estado do formulário
  var isLoading = false.obs;

  // Método para adicionar um cliente
  Future<void> addClient(ClientModel client) async {
    try {
      isLoading.value = true; // Inicia o loading
      await _clientRepository.addClient(client);
      isLoading.value = false; // Para o loading
      Get.snackbar('Sucesso', 'Cliente cadastrado com sucesso!');
    } catch (e) {
      isLoading.value = false; // Para o loading em caso de erro
      Get.snackbar('Erro', 'Erro ao cadastrar cliente: $e');
    }
  }
}
