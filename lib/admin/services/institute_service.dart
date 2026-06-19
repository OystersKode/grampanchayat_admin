import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/institute_model.dart';

class InstituteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final cloudinary = CloudinaryPublic(
    'dv3u8watu', 
    'ml_default', 
    cache: false,
  );

  Stream<List<Institute>> getInstitutes() {
    return _db
        .collection('institutes')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Institute.fromFirestore(doc))
            .toList());
  }

  Future<void> addInstitute(Institute institute) async {
    await _db.collection('institutes').add({
      ...institute.toFirestore(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateInstitute(Institute institute) async {
    await _db.collection('institutes').doc(institute.id).update(institute.toFirestore());
  }

  Future<void> deleteInstitute(String id) async {
    await _db.collection('institutes').doc(id).delete();
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
