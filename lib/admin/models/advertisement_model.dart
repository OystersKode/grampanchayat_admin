import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  final String id;
  final String imageUrl;
  final String title;
  final String description;

  Advertisement({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  factory Advertisement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Advertisement(
      id: doc.id,
      imageUrl: data['image_url'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image_url': imageUrl,
      'title': title,
      'description': description,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
