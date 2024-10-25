

class LeadModel {
  String leadId;
  String name;
  String vendedor;
  String origem;
  String link;

  LeadModel({
    required this.leadId,
    required this.name,
    required this.vendedor,
    required this.origem,
    required this.link,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'leadId': leadId,
      'name': name,
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
      vendedor: json['vendedor'] ?? '',
      origem: json['origem'] ?? '',
      link: json['link'] ?? '',
    );
  }
}
