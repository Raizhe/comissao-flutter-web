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
    int salesCount = await _getCount('contracts');
    int leadsCount = await _getCount('leads');
    int clientsCount = await _getCount('clients');
    int meetingsCount = await _getCount('meets');

    return {
      'sales': salesCount,
      'leads': leadsCount,
      'clients': clientsCount,
      'meetings': meetingsCount,
    };
  }

  Future<Map<String, int>> _fetchSellerPerformance() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('contracts').get();
    Map<String, int> sellerPerformance = {};

    for (var doc in snapshot.docs) {
      String sellerId = doc['sellerId'];
      sellerPerformance[sellerId] = (sellerPerformance[sellerId] ?? 0) + 1;
    }
    return sellerPerformance;
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
            return const Center(
                child: Text('Erro ao carregar o papel do usuário.'));
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
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
                  const Text(
                    'Dashboard Comparativo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFlexibleMetricCard(
                                      'Vendas', data['sales']!, Colors.orange, constraints),
                                  const SizedBox(width: 10),
                                  _buildFlexibleMetricCard(
                                      'Leads', data['leads']!, Colors.blue, constraints),
                                  const SizedBox(width: 10),
                                  _buildFlexibleMetricCard(
                                      'Clientes', data['clients']!, Colors.purple, constraints),
                                ],
                              ),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFlexibleChart(_buildPieChart(data), constraints),
                                  const SizedBox(width: 25),
                                  _buildFlexibleMetricCard(
                                      'Reuniões', data['meetings']!, Colors.green, constraints),
                                  const SizedBox(width: 25),
                                  _buildFlexibleChart(_buildSellerBarChart(data), constraints),
                                ],
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Desempenho dos Vendedores',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              FutureBuilder<Map<String, int>>(
                                future: _fetchSellerPerformance(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Erro ao carregar desempenho dos vendedores.'));
                                  } else {
                                    final sellerData = snapshot.data!;
                                    return _buildSellerBarChart(sellerData);
                                  }
                                },
                              ),
                            ],
                          ),
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
    double height = (constraints.maxWidth / 2) - 20;
    return SizedBox(
      width: width.clamp(200, 400),
      height: height.clamp(100, 200),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
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
      width: size.clamp(300, 400),
      height: size.clamp(300, 400),
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
    final metrics = [
      {'title': 'Leads', 'value': data['leads']!.toDouble(), 'color': Colors.blue},
      {'title': 'Vendas', 'value': data['sales']!.toDouble(), 'color': Colors.orange},
      {'title': 'Clientes', 'value': data['clients']!.toDouble(), 'color': Colors.purple},
      {'title': 'Reuniões', 'value': data['meetings']!.toDouble(), 'color': Colors.green},
    ];

    List<PieChartSectionData> sections = metrics.map((metric) {
      return PieChartSectionData(
        value: (metric['value'] as num).toDouble(),
        color: metric['color'] as Color,
        title: metric['title'] as String,
      );
    }).toList();

    return PieChart(PieChartData(sections: sections));
  }

  Widget _buildSellerBarChart(Map<String, int> sellerData) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    sellerData.forEach((sellerId, count) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(toY: count.toDouble(), color: Colors.blueAccent),
          ],
        ),
      );
    });

    return SizedBox(
      width: 400, // Defina um tamanho explícito
      height: 300, // Defina um tamanho explícito
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: sellerData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }

}
