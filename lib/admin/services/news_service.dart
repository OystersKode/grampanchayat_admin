import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class NewsService {
  NewsService._();

  static final NewsService _instance = NewsService._();
  static NewsService get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Compatibility for main.dart
  static void initialize() {}

  Future<List<Map<String, dynamic>>> fetchNews({int? lastDays}) async {
    Query query = _db.collection('news').orderBy('created_at', descending: true);
    
    if (lastDays != null) {
      final DateTime cutoff = DateTime.now().subtract(Duration(days: lastDays));
      // Start of the day (00:00:00) for better accuracy if needed, 
      // but subtraction is usually fine.
      query = query.where('created_at', isGreaterThanOrEqualTo: cutoff);
    }

    final snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        ...data,
        'id': doc.id,
      };
    }).toList();
  }

  /// Deletes news older than [days] days.
  Future<void> cleanupOldNews(int days) async {
    final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _db.collection('news')
        .where('created_at', isLessThan: cutoff)
        .get();

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> deleteNews(String id) async {
    await _db.collection('news').doc(id).delete();
  }

  Future<void> createNews({
    required String title,
    required String content,
    String headerImageUrl = '',
  }) async {
    final user = AuthService.instance.getCurrentUser();
    // In a real app, you'd fetch the admin's name from their profile doc
    final adminDoc = await _db.collection('admins').doc(user?.uid).get();
    final adminName = adminDoc.data()?['village_name'] ?? 'Admin';

    await _db.collection('news').add({
      'title': title,
      'content': content,
      'header_image_url': headerImageUrl,
      'created_by': user?.uid,
      'created_by_name': adminName,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNews({
    required String id,
    required String title,
    required String content,
    String headerImageUrl = '',
  }) async {
    await _db.collection('news').doc(id).update({
      'title': title,
      'content': content,
      'header_image_url': headerImageUrl,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Firestore doesn't support direct base64 upload to DB (size limits), 
  // but for this task we'll assume the provided URL is used or we use the URL directly.
  // In a real Firebase app, we'd use Firebase Storage.
  // Since the user didn't ask for Storage, I'll keep the signature but return the input if it's already a URL
  // or a placeholder if it's base64 (or ideally the user provides a URL).
  Future<String> uploadImageBase64(String imageBase64) async {
    // For now, return as is or handle logic if needed. 
    // Usually, you'd upload to Firebase Storage here.
    return imageBase64;
  }
}
