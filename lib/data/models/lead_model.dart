class LeadModel {
  String leadId;
  String name; // Nome da Oportunidade
  String sdr;
  String vendedor;
  String origem; // Inbound/Outbound
  String link;

  LeadModel({
    required this.leadId,
    required this.name,
    required this.sdr,
    required this.vendedor,
    required this.origem,
    required this.link,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'leadId': leadId,
      'name': name,
      'sdr': sdr,
      'vendedor': vendedor,
      'origem': origem,
      'link': link,
    };
  }

  // Converter JSON para LeadModel
  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      leadId: json['leadId'] ?? '',
      name: json['name'] ?? '',
      sdr: json['sdr'] ?? '',
      vendedor: json['vendedor'] ?? '',
      origem: json['origem'] ?? '',
      link: json['link'] ?? '',
    );
  }
}
