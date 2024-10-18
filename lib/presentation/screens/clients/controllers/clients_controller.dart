// lib/presentation/screens/clients/controllers/clients_controller.dart
import 'package:get/get.dart';
import '../../../../data/models/clients_model.dart';
import '../../../../data/repositories/client_repository.dart';

class ClientsController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();

  var clients = <ClientModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients(); // Busca clientes ao inicializar
  }

  Future<void> fetchClients() async {
    isLoading.value = true;
    try {
      List<ClientModel> fetchedClients = await _clientRepository.getAllClients();
      clients.value = fetchedClients;
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar clientes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _clientRepository.deleteClient(clientId);
      clients.removeWhere((client) => client.clientId == clientId);
      Get.snackbar('Sucesso', 'Cliente excluído com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao excluir cliente: $e');
    }
  }
}
