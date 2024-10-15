import 'package:comissao_flutter_web/data/models/user_model.dart';
import 'package:comissao_flutter_web/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final roleController = TextEditingController();
  final commissionRateController = TextEditingController();
  final UserRepository userRepository = UserRepository();

  Future<void> addUser() async {
    try {
      String uid = FirebaseFirestore.instance.collection('users').doc().id; // Gerar UID automaticamente
      UserModel newUser = UserModel(
        uid: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: roleController.text.trim(),
        createdAt: DateTime.now(),
        commissionRate: double.tryParse(commissionRateController.text.trim()) ?? 0.0,
      );
      await userRepository.addUser(newUser);
      Get.back(); // Voltar à tela anterior
      Get.snackbar('Sucesso', 'Usuário cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar usuário: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    commissionRateController.dispose();
    super.onClose();
  }
}
