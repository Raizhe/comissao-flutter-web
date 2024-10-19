import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/side_bar_widget.dart';

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

  Future<Map<String, int>> _fetchAllMetrics() async {
    int salesCount = await _getCount('contracts'); // Número de vendas
    int leadsCount = await _getCount('leads'); // Número de leads
    int clientsCount = await _getCount('clients'); // Número de clientes
    int meetingsCount = await _getCount('meets'); // Número de reuniões

    return {
      'sales': salesCount,
      'leads': leadsCount,
      'clients': clientsCount,
      'meetings': meetingsCount,
    };
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, int>>(
          future: _fetchAllMetrics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar métricas.'));
            } else {
              final data = snapshot.data!;
              return Column(
                children: [
                  const Center(
                    child: Text(
                      'Dashboard Comparativo',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFlexibleMetricCard(
                                'Vendas', data['sales']!, Colors.red, constraints),
                            _buildFlexibleMetricCard(
                                'Leads', data['leads']!, Colors.blue, constraints),
                            _buildFlexibleMetricCard(
                                'Clientes', data['clients']!, Colors.purple, constraints),
                            _buildFlexibleMetricCard(
                                'Reuniões', data['meetings']!, Colors.green, constraints),
                            _buildFlexibleChart(_buildPieChart(data), constraints),
                            _buildFlexibleChart(_buildBarChart(data), constraints),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFlexibleMetricCard(
      String title, int value, Color color, BoxConstraints constraints) {
    double width = (constraints.maxWidth / 2) - 20;
    return SizedBox(
      width: width.clamp(150, 300),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlexibleChart(Widget chart, BoxConstraints constraints) {
    double size = (constraints.maxWidth / 2) - 20;
    return SizedBox(
      width: size.clamp(200, 300),
      height: size.clamp(200, 300),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: chart,
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: data['leads']!.toDouble(),
            color: Colors.blue,
            title: 'Leads',
          ),
          PieChartSectionData(
            value: data['sales']!.toDouble(),
            color: Colors.green,
            title: 'Vendas',
          ),
          PieChartSectionData(
            value: data['clients']!.toDouble(),
            color: Colors.purple,
            title: 'Clientes',
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: (data.values.reduce((a, b) => a > b ? a : b)).toDouble() + 10,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: data['leads']!.toDouble(), color: Colors.blue)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: data['sales']!.toDouble(), color: Colors.green)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: data['clients']!.toDouble(), color: Colors.purple)],
          ),
        ],
      ),
    );
  }
}
