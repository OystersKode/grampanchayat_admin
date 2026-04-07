import 'package:cloud_firestore/cloud_firestore.dart';

class MemberRequestsService {
  MemberRequestsService._();

  static final MemberRequestsService _instance = MemberRequestsService._();
  static MemberRequestsService get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static void initialize() {}

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final snapshot = await _db.collection('member_requests')
        .orderBy('created_at', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'id': doc.id,
      };
    }).toList();
  }

  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await _db.collection('member_requests').doc(id).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createMemberRequest(Map<String, dynamic> data) async {
    await _db.collection('member_requests').add({
      ...data,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRequest(String id) async {
    await _db.collection('member_requests').doc(id).delete();
  }
}
