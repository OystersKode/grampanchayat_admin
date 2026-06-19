import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/advertisement_model.dart';

class AdvertisementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final cloudinary = CloudinaryPublic(
    'dv3u8watu', 
    'ml_default', 
    cache: false,
  );

  Stream<List<Advertisement>> getAdvertisements() {
    return _db
        .collection('advertisements')
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Advertisement.fromFirestore(doc))
            .toList());
  }

  Future<void> addAdvertisement(Advertisement ad) async {
    await _db.collection('advertisements').add({
      ...ad.toFirestore(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAdvertisement(Advertisement ad) async {
    await _db.collection('advertisements').doc(ad.id).update(ad.toFirestore());
  }

  Future<void> deleteAdvertisement(String id) async {
    await _db.collection('advertisements').doc(id).delete();
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
