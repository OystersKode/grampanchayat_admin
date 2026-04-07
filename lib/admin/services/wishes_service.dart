import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'auth_service.dart';

class WishesService {
  WishesService._();

  static final WishesService _instance = WishesService._();
  static WishesService get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final cloudinary = CloudinaryPublic(
    'dv3u8watu', 
    'ml_default', 
    cache: false,
  );

  static void initialize() {}

  Future<List<Map<String, dynamic>>> fetchWishes() async {
    final snapshot = await _db.collection('wishes')
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

  Future<void> createWish({
    required String title,
    required String content,
    String headerImageUrl = '',
    String tag = '',
  }) async {
    final user = AuthService.instance.getCurrentUser();
    
    await _db.collection('wishes').add({
      'title': title,
      'content': content,
      'header_image_url': headerImageUrl,
      'tag': tag,
      'created_by': user?.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateWish({
    required String id,
    required String title,
    required String content,
    String headerImageUrl = '',
    String tag = '',
  }) async {
    await _db.collection('wishes').doc(id).update({
      'title': title,
      'content': content,
      'header_image_url': headerImageUrl,
      'tag': tag,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteWish(String id) async {
    await _db.collection('wishes').doc(id).delete();
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
}
