import 'dart:ui';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/lead_model.dart';
import '../../../../data/models/meet_model.dart';
import '../../../../data/repositories/lead_repository.dart';
import '../../../../data/repositories/meet_repository.dart';

class LeadController extends GetxController {
  final LeadRepository _leadRepository = LeadRepository();
  final MeetRepository _meetRepository = MeetRepository();

  var isLoading = false.obs;

  Future<void> addLead(LeadModel lead) async {
    try {
      isLoading(true); // Inicia o carregamento
      await _leadRepository.addLead(lead);
      _showSuccess('Lead cadastrado com sucesso!');
    } catch (e) {
      _showError('Erro ao cadastrar lead: $e');
    } finally {
      isLoading(false); // Finaliza o carregamento
    }
  }

  Future<void> addMeetingForLead(String leadId, DateTime scheduleDate, DateTime? meetingDate) async {
    try {
      isLoading(true);
      String meetId = const Uuid().v4();

      MeetModel meet = MeetModel(
        meetId: meetId,
        leadId: leadId,
        dataAgendamento: scheduleDate,
        dataMeet: meetingDate, // Agora este campo é opcional
        status: 'Não', // Default status
      );

      await _meetRepository.addMeet(meet);
      _showSuccess('Meeting agendado com sucesso!');
    } catch (e) {
      _showError('Erro ao agendar meeting: $e');
    } finally {
      isLoading(false);
    }
  }

  //
  // Future<void> addMeetingForLead(String leadId, DateTime scheduleDate) async {
  //   try {
  //     isLoading(true);
  //     String meetId = const Uuid().v4();
  //
  //     MeetModel meet = MeetModel(
  //       meetId: meetId,
  //       leadId: leadId,
  //       dataAgendamento: scheduleDate,
  //       dataReuniao: null,
  //       status: 'Não', // Default status
  //     );
  //
  //     await _meetRepository.addMeet(meet);
  //     _showSuccess('Meeting agendado com sucesso!');
  //   } catch (e) {
  //     _showError('Erro ao agendar meeting: $e');
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  void _showSuccess(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
    );
  }
}
