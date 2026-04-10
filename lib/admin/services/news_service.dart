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
    'ml_default', 
    cache: false,
  );

  Future<List<Map<String, dynamic>>> fetchNews() async {
    final snapshot = await _db.collection('news').orderBy('created_at', descending: true).get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> deleteNews(String id) async {
    await _db.collection('news').doc(id).delete();
  }

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

  Future<void> createNews({
    required String title,
    required String content,
    String? category,
    String? coverImageUrl,
    List<String>? relatedImages,
  }) async {
    final user = AuthService.instance.getCurrentUser();
    await _db.collection('news').add({
      'title': title,
      'content': content,
      'category': category,
      'cover_image_url': coverImageUrl,
      'related_images': relatedImages ?? [],
      'created_by': user?.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNews({
    required String id,
    required String title,
    required String content,
    String? category,
    String? coverImageUrl,
    List<String>? relatedImages,
  }) async {
    await _db.collection('news').doc(id).update({
      'title': title,
      'content': content,
      'category': category,
      'cover_image_url': coverImageUrl,
      'related_images': relatedImages,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
