import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw Exception('Erro ao adicionar usuário: $e');
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      print('UID buscado: $uid');
      if (doc.exists) {
        print('Documento do usuário encontrado: ${doc.data()}');
        return doc['role'] as String?;
      } else {
        print('Documento não encontrado para o UID: $uid');
      }
      return null;
    } catch (e) {
      print('Erro ao buscar o papel do usuário: $e');
      throw Exception('Erro ao buscar o papel do usuário: $e');
    }
  }
}
