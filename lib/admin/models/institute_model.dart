import 'package:cloud_firestore/cloud_firestore.dart';

class Institute {
  final String id;
  final String name;
  final String imageUrl;
  final String contactNumber;
  final String email;
  final String website;

  Institute({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.contactNumber,
    required this.email,
    required this.website,
  });

  factory Institute.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Institute(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      email: data['email'] ?? '',
      website: data['website'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image_url': imageUrl,
      'contact_number': contactNumber,
      'email': email,
      'website': website,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
