import 'package:get/get.dart';
import '../../../../data/models/meet_model.dart';
import '../../../../data/repositories/meet_repository.dart';

class MeetController extends GetxController {
  final MeetRepository _meetRepository = MeetRepository();
  var isLoading = false.obs;
  var meets = <MeetModel>[].obs;

  Future<void> addMeet(MeetModel meet) async {
    try {
      isLoading.value = true;
      await _meetRepository.addMeet(meet);
      Get.snackbar('Sucesso', 'Reunião cadastrada com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar reunião: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllMeets() async {
    try {
      isLoading.value = true;
      meets.value = await _meetRepository.getAllMeets();
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar reuniões: $e');
    } finally {
      isLoading.value = false;
    }
  }


}
