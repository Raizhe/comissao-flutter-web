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

  // Método para alterar o status de um cliente
  Future<void> updateClientStatus(ClientModel client, String newStatus) async {
    try {
      isLoading.value = true;
      client.status = newStatus; // Atualiza localmente
      await _clientRepository.updateClient(client); // Atualiza no banco
      clients.refresh(); // Atualiza a lista observada
      Get.snackbar('Sucesso', 'Status do cliente atualizado para $newStatus');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao atualizar status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para buscar clientes com base em uma query
  void searchClients(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = clients.where((client) {
      return client.nome.toLowerCase().contains(lowerQuery) ||
          (client.cpfcnpj?.toLowerCase() ?? '').contains(lowerQuery) ||
          (client.telefone?.toLowerCase() ?? '').contains(lowerQuery) ||
          client.status.toLowerCase().contains(lowerQuery);
    }).toList();

    clients.value = filtered; // Atualiza a lista visível
  }

  // Método para ordenar a lista de clientes
  void sortClients(bool isAscending) {
    final sorted = clients.toList();
    sorted.sort((a, b) => isAscending ? a.nome.compareTo(b.nome) : b.nome.compareTo(a.nome));
    clients.value = sorted; // Atualiza a lista ordenada
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
