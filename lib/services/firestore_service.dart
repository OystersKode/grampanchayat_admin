import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------
  // ADMIN METHODS
  // ----------------------------------------

  Future<void> createAdmin(String uid, Map<String, dynamic> data) async {
    await _db.collection('admins').doc(uid).set(data);
  }

  Future<DocumentSnapshot> getAdmin(String adminId) async {
    return await _db.collection('admins').doc(adminId).get();
  }

  // ----------------------------------------
  // NEWS METHODS
  // ----------------------------------------

  Future<DocumentReference> createNews(Map<String, dynamic> newsData) async {
    return await _db.collection('news').add({
      'title': newsData['title'],
      'content': newsData['content'],
      'header_image_url': newsData['header_image_url'],
      'created_by': newsData['created_by'],
      'created_by_name': newsData['created_by_name'],
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNews(String newsId, Map<String, dynamic> newsData) async {
    await _db.collection('news').doc(newsId).update({
      'title': newsData['title'],
      'content': newsData['content'],
      'header_image_url': newsData['header_image_url'],
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<QueryDocumentSnapshot>> getAllNews() async {
    final snapshot = await _db.collection('news')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getNewsById(String newsId) async {
    return await _db.collection('news').doc(newsId).get();
  }

  Future<void> deleteNews(String newsId) async {
    await _db.collection('news').doc(newsId).delete();
  }

  // ----------------------------------------
  // NEWS IMAGES (SUBCOLLECTION)
  // ----------------------------------------

  Future<void> addNewsImage(String newsId, String imageUrl) async {
    await _db.collection('news').doc(newsId).collection('images').add({
      'image_url': imageUrl,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<QueryDocumentSnapshot>> getNewsImages(String newsId) async {
    final snapshot = await _db.collection('news').doc(newsId).collection('images').get();
    return snapshot.docs;
  }

  // ----------------------------------------
  // WISHES METHODS
  // ----------------------------------------

  Future<void> createWish(Map<String, dynamic> wishData) async {
    await _db.collection('wishes').add({
      ...wishData,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<QueryDocumentSnapshot>> getAllWishes() async {
    final snapshot = await _db.collection('wishes')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs;
  }

  // ----------------------------------------
  // MEMBER REQUEST METHODS
  // ----------------------------------------

  Future<void> createMemberRequest(Map<String, dynamic> data) async {
    await _db.collection('member_requests').add({
      ...data,
      'status': data['status'] ?? 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _db.collection('member_requests').doc(requestId).update({
      'status': status,
    });
  }

  // ----------------------------------------
  // LIKES SYSTEM
  // ----------------------------------------

  Future<void> toggleLike(String guestId, String contentId, String contentType) async {
    final query = await _db.collection('likes')
        .where('guest_id', isEqualTo: guestId)
        .where('content_id', isEqualTo: contentId)
        .where('content_type', isEqualTo: contentType)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Unlike
      await _db.collection('likes').doc(query.docs.first.id).delete();
    } else {
      // Like
      await _db.collection('likes').add({
        'guest_id': guestId,
        'content_id': contentId,
        'content_type': contentType,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // ----------------------------------------
  // USER ACTIVITY
  // ----------------------------------------

  Future<void> logActivity(String guestId, String action) async {
    await _db.collection('user_activity').add({
      'guest_id': guestId,
      'action': action,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
