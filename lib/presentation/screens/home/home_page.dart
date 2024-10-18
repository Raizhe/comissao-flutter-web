import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/side_bar_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  final UserRepository userRepository = UserRepository();

  HomePage({Key? key}) : super(key: key);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offNamed('/login');
  }

  Future<int> _getCount(String collection) async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection(collection).get();
      return snapshot.size;
    } catch (e) {
      print('Erro ao buscar contagem: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      drawer: FutureBuilder<String?>(
        future: userRepository.getUserRole(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            String? role = snapshot.data;
            return SidebarWidget(role: role!);
          } else {
            return const Center(child: Text('Erro ao carregar o papel do usuário.'));
          }
        },
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados.'));
          } else {
            final data = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildChart('Leads', data['leads']!, Colors.blue, 'linha'),
                    _buildChart('Contratos', data['contracts']!, Colors.green, 'coluna'),
                    _buildChart('Clientes', data['clients']!, Colors.deepPurple , 'pizza'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, int>> _fetchData() async {
    int leadsCount = await _getCount('leads');
    int contractsCount = await _getCount('contracts');
    int clientsCount = await _getCount('clients');

    return {
      'leads': leadsCount,
      'contracts': contractsCount,
      'clients': clientsCount,
    };
  }

  Widget _buildChart(String title, int value, Color color, String type) {
    switch (type) {
      case 'linha':
        return _buildLineChart(title, value, color);
      case 'coluna':
        return _buildBarChart(title, value, color);
      case 'pizza':
        return _buildPieChart(title, value, color);
      default:
        return const Text('Tipo de gráfico não encontrado.');
    }
  }

  Widget _buildLineChart(String title, int value, Color color) {
    return _buildCard(
      title,
      LineChart(
        LineChartData(
          minY: 0,
          maxY: (value + 10).toDouble(),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.black, width: 2),
              left: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          titlesData: FlTitlesData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [FlSpot(0, 0), FlSpot(1, value.toDouble())],
              isCurved: true,
              barWidth: 3,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(String title, int value, Color color) {
    return _buildCard(
      title,
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: value.toDouble() + 10,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  color: color,
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title, int value, Color color) {
    return _buildCard(
      title,
      PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: value.toDouble(),
              color: color,
              radius: 50,
              title: '$value',
              titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget chart) {
    return SizedBox(
      width: 400,
      height: 350,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(child: chart),
            ],
          ),
        ),
      ),
    );
  }
}
