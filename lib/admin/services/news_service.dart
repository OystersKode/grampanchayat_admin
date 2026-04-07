import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'auth_service.dart';

class NewsService {
  NewsService._();

  static final NewsService _instance = NewsService._();
  static NewsService get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final cloudinary = CloudinaryPublic(
    'dv3u8watu', 
    'ml_default', // We'll need to make sure unsigned upload is enabled or use a preset
    cache: false,
  );

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
    List<String> relatedImageUrls = const [],
  }) async {
    final user = AuthService.instance.getCurrentUser();
    final adminDoc = await _db.collection('admins').doc(user?.uid).get();
    final adminName = adminDoc.data()?['village_name'] ?? 'Admin';

    await _db.collection('news').add({
      'title': title,
      'content': content,
      'header_image_url': headerImageUrl,
      'related_image_urls': relatedImageUrls,
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
    List<String> relatedImageUrls = const [],
  }) async {
    await _db.collection('news').doc(id).update({
      'title': title,
      'content': content,
      'header_image_url': headerImageUrl,
      'related_image_urls': relatedImageUrls,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Upload to Cloudinary
  Future<String> uploadImage(String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      throw Exception('Failed to upload image to Cloudinary');
    }
  }
}
