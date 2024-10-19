import 'package:flutter/material.dart';
import '../../../data/models/meet_model.dart';
import '../../../data/repositories/meet_repository.dart';

class MeetPage extends StatelessWidget {
  final MeetRepository _meetRepository = MeetRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reuniões Agendadas'),
      ),
      body: FutureBuilder<List<MeetModel>>(
        future: _meetRepository.getAllMeets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar reuniões.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhuma reunião agendada.'),
            );
          } else {
            final meets = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: meets.length,
              itemBuilder: (context, index) {
                final meet = meets[index];
                return _buildMeetCard(meet);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMeetCard(MeetModel meet) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text('Reunião ID: ${meet.meetId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lead ID: ${meet.leadId}'),
            Text('Data Agendamento: ${meet.dataAgendamento}'),
            Text('Data da Reunião: ${meet.dataMeet ?? 'Não definida'}'),
            Text('Status: ${meet.status}'),
          ],
        ),
      ),
    );
  }
}
