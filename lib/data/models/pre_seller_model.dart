class PreSellerModel {
  final String preSellerId;
  final String name;
  final String email;
  final double comissao; // Alterado de commissionRate para comissao
  final DateTime createdAt;
  final List<String> clients;

  PreSellerModel({
    required this.preSellerId,
    required this.name,
    required this.email,
    required this.comissao,
    required this.createdAt,
    required this.clients,
  });

  // Converter para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'preSellerId': preSellerId,
      'name': name,
      'email': email,
      'comissao': comissao,
      'createdAt': createdAt.toIso8601String(),
      'clients': clients,
    };
  }

  // Criar objeto PreSellerModel a partir de Map (Firestore)
  factory PreSellerModel.fromMap(Map<String, dynamic> map) {
    return PreSellerModel(
      preSellerId: map['preSellerId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      comissao: map['comissao']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
      clients: List<String>.from(map['clients'] ?? []),
    );
  }
}
