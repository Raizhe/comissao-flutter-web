import 'package:flutter/material.dart';

class LeadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Leads'),
      ),
      body: Center(
        child: Text('Aqui vai a lista de Leads.'),
      ),
    );
  }
}
