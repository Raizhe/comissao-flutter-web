import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/monthly_carousel_widget.dart';
import '../../../widgets/side_bar_widget.dart';
import '../../../widgets/client_status_overview_widget.dart';
import '../clients/controllers/clients_controller.dart';
import '../contract/controllers/contracts_controller.dart';
import 'package:rxdart/rxdart.dart' as rxd;
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserRepository userRepository = UserRepository();
  late Future<Map<String, int>> metricsFuture;
  final ClientsController clientsController = Get.put(ClientsController());
  final ContractController contractController = Get.put(ContractController());

  final List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  String selectedMonth = DateTime.now().month.toString(); // Mês atual
  late int selectedMonthIndex;
  Map<String, Map<String, int>> monthlyDataMap = {};
  Map<String, int> monthlyData = {};
  int _currentIndex = 0;



// Stream que combina os dados de contracts e clients em tempo real
  Stream<Map<String, int>> _combinedMetricsStream() {
    final contractsStream =
        FirebaseFirestore.instance.collection('contracts').snapshots();
    final clientsStream =
        FirebaseFirestore.instance.collection('clients').snapshots();

    return rxd.Rx.combineLatest2<QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>, Map<String, int>>(
      contractsStream,
      clientsStream,
      (contractsSnapshot, clientsSnapshot) {
        // Processamento dos contratos
        final activeContractsCount = contractsSnapshot.docs
            .where((doc) => doc['status'] == 'Ativo')
            .length;
        final inactiveContractsCount = contractsSnapshot.docs
            .where((doc) => doc['status'] == 'Cancelado')
            .length;
        final stoppedContractsCount = contractsSnapshot.docs
            .where((doc) => doc['status'] == 'Pausado')
            .length;

        // Processamento dos clientes
        final activeClientsCount = clientsSnapshot.docs
            .where((doc) => doc['status'] == 'Ativo')
            .length;
        final inactiveClientsCount = clientsSnapshot.docs
            .where((doc) => doc['status'] == 'Inativo')
            .length;
        final canceledClientsCount = clientsSnapshot.docs
            .where((doc) => doc['status'] == 'Cancelado')
            .length;
        final downsellClientsCount = clientsSnapshot.docs
            .where((doc) => doc['status'] == 'Downsell')
            .length;

        return {
          'activeContracts': activeContractsCount,
          'inactiveContracts': inactiveContractsCount,
          'stoppedContracts': stoppedContractsCount,
          'activeClients': activeClientsCount,
          'inactiveClients': inactiveClientsCount,
          'canceledClients': canceledClientsCount,
          'downsellClients': downsellClientsCount,
        };
      },
    );
  }

  Stream<Map<String, int>> _metricsStream() {
    // Escuta atualizações em tempo real na coleção de contratos
    return FirebaseFirestore.instance
        .collection('contracts')
        .snapshots()
        .map((snapshot) {
      int salesCount = 0;
      int clientsCount = 0; // Total de clientes (ajuste conforme necessário)

      // Variáveis para contar o status dos contratos
      int activeContractsCount = 0;
      int inactiveContractsCount = 0;
      int stoppedContractsCount = 0;
      int downsellContractsCount = 0;
      int encerramentoContractsCount = 0;
      int renovadoContractsCount = 0;
      int renovacaoAutomaticaContractsCount = 0;
      int upsellContractsCount = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data();
        salesCount++;

        // Contagem de contratos conforme o status
        switch (data['status']) {
          case 'Ativo':
            activeContractsCount++;
            break;
          case 'Cancelado':
            inactiveContractsCount++;
            break;
          case 'Pausado':
            stoppedContractsCount++;
            break;
          case 'Downsell':
            downsellContractsCount++;
            break;
          case 'Encerramento':
            encerramentoContractsCount++;
            break;
          case 'Renovado':
            renovadoContractsCount++;
            break;
          case 'Renovação Automática':
            renovacaoAutomaticaContractsCount++;
            break;
          case 'Upsell':
            upsellContractsCount++;
            break;
          default:
            break;
        }
      }

      return {
        'sales': salesCount,
        'clients': clientsCount,
        'activeContracts': activeContractsCount,
        'inactiveContracts': inactiveContractsCount,
        'stoppedContracts': stoppedContractsCount,
        'downsellContracts': downsellContractsCount,
        'encerramentoContracts': encerramentoContractsCount,
        'renovadoContracts': renovadoContractsCount,
        'renovacaoAutomaticaContracts': renovacaoAutomaticaContractsCount,
        'upsellContracts': upsellContractsCount,
      };
    });
  }

  Stream<int> _clientsStream() {
    return FirebaseFirestore.instance
        .collection('clients')
        .snapshots()
        .map((snapshot) {
      return snapshot.size;
    });
  }

  void _onMonthSelected(String month) {
    setState(() {
      selectedMonthIndex = months.indexOf(month);
      selectedMonth = month;
      if (monthlyDataMap.containsKey(selectedMonth)) {
        monthlyData = monthlyDataMap[selectedMonth]!;
      } else {
        monthlyData = {};
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMonthlySalesData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('contracts').get();
      // Mapeia os meses e soma as vendas para cada mês
      Map<int, double> monthlySales = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          // Validação de `startDate`
          DateTime? startDate;
          if (data['startDate'] is Timestamp) {
            startDate = (data['startDate'] as Timestamp).toDate();
          } else {
            continue; // Ignora documentos inválidos
          }
          // Validação de `feeMensal`
          double feeMensal = data['feeMensal']?.toDouble() ?? 0.0;
          // Garantir que a data de início seja válida
          if (startDate != null) {
            int month = startDate.month;
            monthlySales[month] = (monthlySales[month] ?? 0) + feeMensal;
          }
        }
      }
      // Converte o Map em uma lista para o gráfico
      return monthlySales.entries
          .map((entry) => {'month': entry.key, 'amount': entry.value})
          .toList();
    } catch (e) {
      print('Erro ao carregar dados: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> _fetchMetricsForMonth(int month) async {
    final startOfMonth = DateTime(DateTime.now().year, month, 1);
    final endOfMonth = DateTime(DateTime.now().year, month + 1, 1)
        .subtract(const Duration(days: 1));

    // Filtra os contratos do mês
    final contractSnapshot = await FirebaseFirestore.instance
        .collection('contracts')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    // Filtra os clientes do mês
    final clientSnapshot = await FirebaseFirestore.instance
        .collection('clients')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final activeContractsCount =
        contractSnapshot.docs.where((doc) => doc['status'] == 'Ativo').length;
    final inactiveContractsCount = contractSnapshot.docs
        .where((doc) => doc['status'] == 'Cancelado')
        .length;
    final stoppedContractsCount =
        contractSnapshot.docs.where((doc) => doc['status'] == 'Pausado').length;
    final activeClientsCount =
        clientSnapshot.docs.where((doc) => doc['status'] == 'Ativo').length;

    return {
      'contracts': activeContractsCount,
      'inactiveContracts': inactiveContractsCount,
      'stoppedContracts': stoppedContractsCount,
      'clients': activeClientsCount,
    };
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offNamed('/login');
  }

  Future<String> _fetchUserName(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return snapshot.data()?['name'] ?? 'Usuário';
    } catch (e) {
      print('Erro ao buscar nome do usuário: $e');
      return 'Usuário';
    }
  }

  Future<Map<String, int>> _fetchALLMetrics() async {
    int salesCount = await _getCount('contracts');
    int clientsCount = await _getCount('clients', status: 'Ativo');
    int activeContractsCount = await _getCount('contracts', status: 'Ativo');
    int inactiveContractsCount =
        await _getCount('contracts', status: 'Cancelado');
    int stoppedContractsCount = await _getCount('contracts',
        status: 'Pausado'); // Verifique se o status é "cancelado" no Firestore

    return {
      'sales': salesCount,
      'clients': clientsCount,
      'contracts': activeContractsCount,
      'inactiveContracts': inactiveContractsCount,
      'stoppedContracts': stoppedContractsCount,
      // Inclui contratos cancelados
    };
  }

  Future<Map<String, String>> _fetchSellerNames() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('sellers').get();
    return {
      for (var doc in snapshot.docs) doc.id: doc['name'] ?? 'Desconhecido',
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

  Future<int> _getCount(String collectionName, {String? status}) async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(collectionName);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.size;
  }

  Future<List<Map<String, dynamic>>> _fetchUpcomingPayments() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('clients')
        .where('dataVencimentoPagamento', isNotEqualTo: null)
        .where('reminderAcknowledged', isEqualTo: false)
        .get();

    List<Map<String, dynamic>> upcomingPayments = [];

    DateTime now = DateTime.now();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null &&
          data.containsKey('dataVencimentoPagamento') &&
          data['dataVencimentoPagamento'] != null &&
          data['dataVencimentoPagamento'] is Timestamp) {
        DateTime dueDate =
            (data['dataVencimentoPagamento'] as Timestamp).toDate();

        if (dueDate.difference(now).inDays <= 5 && dueDate.isAfter(now)) {
          upcomingPayments.add({
            'clientId': doc.id, // Usando `doc.id` para o ID do documento
            'nome': data['nome'] ?? 'Cliente sem nome',
            'dataVencimentoPagamento': dueDate,
          });
        }
      } else {
        print(
            "Erro: 'dataVencimentoPagamento' está ausente ou não é Timestamp para o documento ${doc.id}");
      }
    }

    // Log de depuração
    for (var payment in upcomingPayments) {
      print(
          "Lembrete para ${payment['nome']} com vencimento em ${payment['dataVencimentoPagamento']}");
    }

    return upcomingPayments;
  }

  void refreshMetrics() {
    setState(() {
      metricsFuture = _fetchALLMetrics();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedMonthIndex = DateTime.now().month - 1; // Mês atual como índice
    selectedMonth = months[selectedMonthIndex]; // Nome do mês atual
    _fetchMetricsForMonth(selectedMonthIndex + 1).then((data) {
      setState(() {
        monthlyData = data; // Dados iniciais
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedMonthIndex = DateTime.now().month - 1; // Mês atual como índice
    selectedMonth = months[selectedMonthIndex]; // Nome do mês atual
    refreshMetrics();
  }

  @override
  void dispose() {
    //_pageController.dispose();
    Get.delete<ClientsController>();
    Get.delete<ContractController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _fetchUserName(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Carregando...');
            } else if (snapshot.hasError) {
              return const Text('Erro ao carregar nome');
            } else {
              return Text('Bem-vindo, ${snapshot.data}');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      drawer: FutureBuilder<String?>(
        future: userRepository.getUserRole(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return SidebarWidget(role: snapshot.data!);
          } else {
            return const Center(
                child: Text('Erro ao carregar o papel do usuário.'));
          }
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<Map<String, int>>(
                stream: _combinedMetricsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Erro ao carregar métricas.'));
                  } else {
                    final data = snapshot.data!;
                    monthlyDataMap[selectedMonth] = data;
                    monthlyData = data;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Drop Lead Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Selecione o mês: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            DropdownButton<String>(
                              value: selectedMonth,
                              items: months.map((month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(month),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _onMonthSelected(value);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          child: monthlyData.isNotEmpty
                              ? MonthlyCarouselWidget(
                            monthlyData: monthlyData,
                            selectedMonth: selectedMonth,
                            onPageChanged: (index) {

                                _currentIndex = index;

                            },
                          )
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          if (clientsController.isLoading.value ||
                              contractController.isLoading.value) {
                            return const CircularProgressIndicator();
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: ClientStatusOverviewWidget(
                                clientData: clientsController.clients
                                    .map((client) => client.toJson())
                                    .toList(),
                              ),
                            );
                          }
                        }),
                        const SizedBox(height: 40),
                        _buildSellerCommissionsCard(),
                        const SizedBox(height: 40),
                        Wrap(
                          spacing: 20.0,
                          runSpacing: 20.0,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width > 600
                                  ? 500
                                  : double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Desempenho dos Vendedores',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FutureBuilder<Map<String, int>>(
                                    future: _fetchSellerPerformance(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return const Text(
                                            'Erro ao carregar desempenho.');
                                      } else {
                                        final sellerData = snapshot.data!;
                                        return FutureBuilder<
                                            Map<String, String>>(
                                          future: _fetchSellerNames(),
                                          builder: (context, nameSnapshot) {
                                            if (nameSnapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            } else if (nameSnapshot.hasError) {
                                              return const Text(
                                                  'Erro ao carregar nomes.');
                                            } else {
                                              final sellerNames =
                                                  nameSnapshot.data!;
                                              return SizedBox(
                                                height: 300,
                                                child: _buildPieChart(
                                                    sellerData, sellerNames),
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width > 600
                                  ? 500
                                  : double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Crescimento vendas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 300,
                                    child: _buildSalesGrowthChart(),
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ],
                        ),

                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentReminderWidget() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUpcomingPayments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print("Nenhum lembrete para exibir.");
          return const SizedBox
              .shrink(); // Retorna vazio se não houver lembrete
        }

        final payments = snapshot.data!;
        print("Exibindo lembrete para ${payments.length} pagamentos.");

        return GestureDetector(
          onTap: () => _showReminderModal(context, payments),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.purple, // Fundo roxo
              borderRadius: BorderRadius.circular(16.0), // Bordas arredondadas
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Pagamentos a vencer:',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  payments.map((p) => p['nome']).join(", "),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReminderModal(
      BuildContext context, List<Map<String, dynamic>> payments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso de Vencimento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: payments.map((payment) {
              return ListTile(
                title: Text(payment['nome']),
                subtitle: Text(
                    'Vencimento em ${DateFormat('dd/MM/yyyy').format(payment['dataVencimentoPagamento'])}'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            TextButton(
              onPressed: () async {
                // Atualiza cada cliente para que o lembrete não apareça mais
                for (var payment in payments) {
                  await FirebaseFirestore.instance
                      .collection('contracts')
                      .doc(payment['contractsId'])
                      .update({'reminderAcknowledged': true});
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart(
      Map<String, int> sellerData, Map<String, String> sellerNames) {
    final colors = Colors.primaries;

    // Filtrar apenas vendedores com valores maiores que 0.
    final filteredData = sellerData.entries
        .where((entry) => entry.value > 0 && sellerNames.containsKey(entry.key))
        .toList();

    // Verificar se há dados para mostrar. Se não houver, mostrar um fallback.
    if (filteredData.isEmpty) {
      return const Center(
        child: Text('Nenhum dado disponível para os vendedores'),
      );
    }

    return SizedBox(
      width: 300,
      height: 300,
      child: PieChart(
        PieChartData(
          sections: filteredData.map((entry) {
            final sellerName = sellerNames[entry.key] ?? 'Desconhecido';
            final colorIndex = filteredData.indexOf(entry) % colors.length;

            return PieChartSectionData(
              value: entry.value.toDouble(),
              color: colors[colorIndex],
              title: sellerName,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Cor do texto para maior visibilidade
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<Map<String, double>> _fetchCommissions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('contracts').get();

    Map<String, double> sellerCommissions = {};

    for (var doc in snapshot.docs) {
      String sellerId = doc['sellerId'];
      double amount = doc['amount']?.toDouble() ?? 0.0;
      String paymentMethod = doc['paymentMethod'];

      double commissionRate = 0.0;
      if (paymentMethod == 'Cartão') {
        commissionRate = (doc['installments'] ?? 0) >= 8 ? 0.25 : 0.20;
      } else if (paymentMethod == 'Boleto') {
        commissionRate = (doc['installments'] ?? 0) >= 8 ? 0.15 : 0.12;
      } else {
        commissionRate = 0.10; // Outros métodos
      }

      double commission = amount * commissionRate;

      sellerCommissions[sellerId] =
          (sellerCommissions[sellerId] ?? 0) + commission;
    }

    return sellerCommissions;
  }

  Future<List<Map<String, dynamic>>> _fetchWeeklySalesData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('contracts').get();

      Map<int, double> weeklySales = {}; // Total por semana

      for (var doc in snapshot.docs) {
        // Faz o cast seguro para Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime startDate = (data['startDate'] as Timestamp).toDate();
          double feeMensal =
              data.containsKey('feeMensal') && data['feeMensal'] != null
                  ? data['feeMensal'].toDouble()
                  : 0.0; // Define como 0.0 se o campo não existir ou for nulo

          // Distribui o feeMensal para cada semana do contrato até a semana atual
          for (int week = _getWeekOfYear(startDate);
              week <= _getWeekOfYear(DateTime.now());
              week++) {
            weeklySales[week] = (weeklySales[week] ?? 0) + feeMensal;
          }

          // Log para verificar os dados
          print('Document data: $data');
          if (data.containsKey('feeMensal')) {
            print('feeMensal: ${data['feeMensal']}');
          }
        }
      }

      // Converte o Map para uma lista ordenada por semana
      return weeklySales.entries
          .map((entry) => {'week': entry.key, 'amount': entry.value})
          .toList();
    } catch (e) {
      print('Erro ao carregar dados: $e');
      rethrow; // Lança o erro novamente para ser tratado no FutureBuilder
    }
  }

  Widget _buildSellerCommissionsCard() {
    return FutureBuilder<Map<String, double>>(
      future: _fetchCommissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar comissões.');
        } else {
          final commissions = snapshot.data!;
          return FutureBuilder<Map<String, String>>(
            future: _fetchSellerNames(),
            builder: (context, nameSnapshot) {
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (nameSnapshot.hasError) {
                return const Text('Erro ao carregar nomes.');
              } else {
                final sellerNames = nameSnapshot.data!;
                final sortedCommissions = commissions.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return SizedBox(
                  width: 400,
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Comissões por Vendedor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...sortedCommissions.asMap().entries.map((entry) {
                            int index = entry.key;
                            MapEntry<String, double> commissionEntry =
                                entry.value;
                            String sellerName =
                                sellerNames[commissionEntry.key] ??
                                    'Desconhecido';
                            double commission = commissionEntry.value;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                    sellerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (index == 0) ...[
                                    const SizedBox(width: 8),
                                    // Space before the trophy
                                    Icon(
                                      Icons.emoji_events, // Trophy icon
                                      color: Colors.amber, // Gold color
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(
                                    'Comissão: R\$ ${commission.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  // Função para calcular a semana do ano
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 5).ceil();
  }

  Widget _buildLineChart(List<Map<String, dynamic>> salesData) {
    double maxY = salesData
            .map((e) => e['amount'] as double)
            .reduce((a, b) => a > b ? a : b) +
        5;

    return SizedBox(
      width: 400,
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(salesData.length, (index) {
                double amount = salesData[index]['amount'];
                return FlSpot(index.toDouble(), amount);
              }),
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${value.toInt()}',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < salesData.length) {
                    String weekLabel = _getWeekLabel(salesData[index]['week']);
                    return Text(
                      weekLabel,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
                interval: 1,
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildMonthlySalesLineChart(List<Map<String, dynamic>> salesData) {
    if (salesData.isEmpty) {
      return const Center(
        child: Text('Nenhum dado disponível para exibir.'),
      );
    }

    // Determinar os valores mínimo e máximo
    double minY = salesData
            .map((e) => e['amount'] as double)
            .reduce((a, b) => a < b ? a : b) -
        10;
    double maxY = salesData
            .map((e) => e['amount'] as double)
            .reduce((a, b) => a > b ? a : b) +
        10;

    return SizedBox(
      width: 400,
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: salesData.map((entry) {
                int month = entry['month'] ?? 0;
                double amount = entry['amount'] ?? 0.0;
                return FlSpot(month.toDouble(), amount);
              }).toList(),
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          minY: minY,
          // Valor mínimo para o eixo Y
          maxY: maxY,
          // Valor máximo para o eixo Y
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (maxY - minY) / 5, // Define intervalos regulares
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${value.toInt()}',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  List<String> months = [
                    'Jan',
                    'Fev',
                    'Mar',
                    'Abr',
                    'Mai',
                    'Jun',
                    'Jul',
                    'Ago',
                    'Set',
                    'Out',
                    'Nov',
                    'Dez'
                  ];
                  int monthIndex = value.toInt() - 1;
                  if (monthIndex >= 0 && monthIndex < months.length) {
                    return Text(months[monthIndex],
                        style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink();
                },
                interval: 1,
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  // Função para gerar o nome abreviado da semana (Ex: "Sem 42")
  String _getWeekLabel(int weekNumber) {
    return 'Sem ${weekNumber.toString()}';
  }

  Widget _buildSalesGrowthChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMonthlySalesData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Text('Nenhum dado disponível.');
        } else {
          final weeklySalesData = snapshot.data!;
          return _buildMonthlySalesLineChart(snapshot.data!);
        }
      },
    );
  }
}
