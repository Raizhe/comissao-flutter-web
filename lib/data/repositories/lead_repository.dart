import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

class LeadRepository {
  final CollectionReference leadsCollection =
  FirebaseFirestore.instance.collection('leads');

  Future<void> addLead(LeadModel lead) async {
    await leadsCollection.doc(lead.leadId).set(lead.toJson());
  }

  Future<List<LeadModel>> getAllLeads() async {
    QuerySnapshot snapshot = await leadsCollection.get();
    return snapshot.docs
        .map((doc) => LeadModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
