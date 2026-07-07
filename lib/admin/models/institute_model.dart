import 'package:cloud_firestore/cloud_firestore.dart';

class Institute {
  final String id;
  final String name;
  final String imageUrl;
  final String contactNumber;
  final String email;
  final String website;
  final bool sendNotification;
  final bool notificationSent;

  Institute({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.contactNumber,
    required this.email,
    required this.website,
    this.sendNotification = true,
    this.notificationSent = false,
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
      sendNotification: data['send_notification'] ?? true,
      notificationSent: data['notification_sent'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image_url': imageUrl,
      'contact_number': contactNumber,
      'email': email,
      'website': website,
      'send_notification': sendNotification,
      'notification_sent': notificationSent,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
