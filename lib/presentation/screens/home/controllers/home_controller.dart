import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repositories/user_repository.dart';

class HomeController extends GetxController {
  final UserRepository userRepository = UserRepository();
  var role = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userRole = await userRepository.getUserRole(user.uid);
        role.value = userRole ?? 'Sem papel';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
