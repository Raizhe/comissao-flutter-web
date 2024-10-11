// lib/data/repositories/user_repository.dart
// lib/data/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  // Adicionar um novo usuário ao Firestore
  Future<void> addUser(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw Exception('Erro ao adicionar usuário: $e');
    }
  }

  // Buscar um usuário por UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }
}
