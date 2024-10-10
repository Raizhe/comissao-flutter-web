class PreSellerModel {
  final String preSellerId;
  final String name;
  final String email;
  final double commissionRate;
  final DateTime createdAt;
  final List<String> clients;

  PreSellerModel({
    required this.preSellerId,
    required this.name,
    required this.email,
    required this.commissionRate,
    required this.createdAt,
    required this.clients,
  });

  // Função para converter o objeto em um Map para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'preSellerId': preSellerId,
      'name': name,
      'email': email,
      'commissionRate': commissionRate,
      'createdAt': createdAt.toIso8601String(),
      'clients': clients,
    };
  }

  // Função para criar um objeto PreSellerModel a partir de um Map (Firestore)
  factory PreSellerModel.fromMap(Map<String, dynamic> map) {
    return PreSellerModel(
      preSellerId: map['preSellerId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      commissionRate: map['commissionRate']?.toDouble() ?? 0.25,
      createdAt: DateTime.parse(map['createdAt']),
      clients: List<String>.from(map['clients'] ?? []),
    );
  }
}
