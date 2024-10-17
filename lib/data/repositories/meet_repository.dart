import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meet_model.dart';

class MeetRepository {
  final CollectionReference meetCollection =
  FirebaseFirestore.instance.collection('meets');

  Future<void> addMeet(MeetModel meet) async {
    await meetCollection.doc(meet.meetId).set(meet.toJson());
  }

  Future<List<MeetModel>> getAllMeets() async {
    QuerySnapshot snapshot = await meetCollection.get();
    return snapshot.docs
        .map((doc) => MeetModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
