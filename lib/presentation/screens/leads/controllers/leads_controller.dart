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

  // Adicionar um novo lead e agendar reunião automaticamente
  Future<void> addLeadAndMeeting(
      LeadModel lead, DateTime scheduleDate, DateTime? meetingDate) async {
    try {
      isLoading(true); // Inicia carregamento

      // Adiciona o lead ao Firestore
      await _leadRepository.addLead(lead);

      // Cria reunião com nome do lead
      String meetId = const Uuid().v4();
      MeetModel meet = MeetModel(
        meetId: meetId,
        leadId: lead.leadId,
        dataAgendamento: scheduleDate,
        dataMeet: meetingDate,
        status: 'Não', // Status inicial
        name: lead.name, // Nome do lead
      );

      // Adiciona a reunião ao Firestore
      await _meetRepository.addMeet(meet);

      // Mensagem de sucesso
      _showSuccess('Lead e reunião cadastrados com sucesso!');
    } catch (e) {
      _showError('Erro ao cadastrar lead e reunião: $e');
    } finally {
      isLoading(false); // Finaliza carregamento
    }
  }

  // Exibir mensagem de sucesso
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

  // Exibir mensagem de erro
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
