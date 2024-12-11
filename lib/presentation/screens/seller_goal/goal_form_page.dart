import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';

import 'controllers/goal_controller.dart';


class GoalFormPage extends StatelessWidget {
  GoalFormPage({Key? key}) : super(key: key);

  final GoalController controller = Get.put(GoalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('Cadastrar Metas'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600,
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cadastro de Metas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormFields(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: controller.addGoal,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(controller.closersGoalController, 'Meta Closers (R\$)'),
        const SizedBox(height: 16),
        _buildTextField(controller.mrrGoalController, 'Meta MRR (R\$)'),
        const SizedBox(height: 16),
        _buildTextField(controller.jobGoalController, 'Meta Job (R\$)'),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType? type]) {
    return TextField(
      controller: controller,
      keyboardType: type ?? TextInputType.number,
      inputFormatters: [
        MoneyInputFormatter(
          thousandSeparator: ThousandSeparator.Period,
          leadingSymbol: "R\$",
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
