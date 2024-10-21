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

  // Método para buscar clientes do banco
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

  // Método para adicionar cliente ao banco
  Future<void> addClient(ClientModel client) async {
    isLoading.value = true;
    try {
      await _clientRepository.addClient(client);
      clients.add(client); // Adiciona à lista local
      Get.snackbar('Sucesso', 'Cliente cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar cliente: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
