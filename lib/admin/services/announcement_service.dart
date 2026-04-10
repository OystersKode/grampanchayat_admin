import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class AnnouncementService {
  AnnouncementService._();
  static final AnnouncementService _instance = AnnouncementService._();
  static AnnouncementService get instance => _instance;

  static void initialize() {}

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final snapshot = await _db.collection('announcements').orderBy('created_at', descending: true).get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    String? category,
  }) async {
    final user = AuthService.instance.getCurrentUser();
    await _db.collection('announcements').add({
      'title': title,
      'content': content,
      'category': category,
      'created_by': user?.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String content,
    String? category,
  }) async {
    await _db.collection('announcements').doc(id).update({
      'title': title,
      'content': content,
      'category': category,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
