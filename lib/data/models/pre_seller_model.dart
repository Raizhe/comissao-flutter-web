class PreSellerModel {
  final String preSellerId;
  final String name;
  final String email;
  final double comissao;
  final DateTime createdAt;

  PreSellerModel({
    required this.preSellerId,
    required this.name,
    required this.email,
    required this.comissao,
    required this.createdAt,

  });

  // Criar objeto PreSellerModel a partir de Map (Firestore)
  factory PreSellerModel.fromMap(Map<String, dynamic> map) {
    return PreSellerModel(
      preSellerId: map['preSellerId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      comissao: map['comissao']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Converter para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'preSellerId': preSellerId,
      'name': name,
      'email': email,
      'comissao': comissao,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
