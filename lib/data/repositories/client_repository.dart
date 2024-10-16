import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar um novo cliente ao Firestore
  Future<void> addClient(ClientModel client) async {
    try {
      await _firestore.collection('clients').doc(client.clientId).set(client.toJson());
    } catch (e) {
      throw Exception('Erro ao adicionar cliente: $e');
    }
  }

  // Atualizar dados de um cliente existente
  Future<void> updateClient(ClientModel client) async {
    try {
      await _firestore.collection('clients').doc(client.clientId).update(client.toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  // Ler dados de um cliente pelo ID
  Future<ClientModel> getClient(String clientId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('clients').doc(clientId).get();
      return ClientModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  // Deletar um cliente
  Future<void> deleteClient(String clientId) async {
    try {
      await _firestore.collection('clients').doc(clientId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }
}
