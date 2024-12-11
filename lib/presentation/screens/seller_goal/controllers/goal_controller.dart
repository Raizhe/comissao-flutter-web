// Goal Controller (goal_controller.dart)
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalController extends GetxController {
  final closersGoalController = TextEditingController();
  final mrrGoalController = TextEditingController();
  final jobGoalController = TextEditingController();
  final goalsRef = FirebaseFirestore.instance.collection('goals');

  Future<void> addGoal() async {
    try {
      await goalsRef.add({
        'metaClosers': double.parse(closersGoalController.text.trim()),
        'metaMRR': double.parse(mrrGoalController.text.trim()),
        'metaJob': double.parse(jobGoalController.text.trim()),
        'createdAt': Timestamp.now(),
      });
      Get.back(); // Voltar para a página anterior
      Get.snackbar('Sucesso', 'Meta cadastrada com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar metas: $e');
    }
  }

  @override
  void onClose() {
    closersGoalController.dispose();
    mrrGoalController.dispose();
    jobGoalController.dispose();
    super.onClose();
  }
}