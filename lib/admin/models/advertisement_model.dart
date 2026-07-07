import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final bool sendNotification;
  final bool notificationSent;

  Advertisement({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.sendNotification = true,
    this.notificationSent = false,
  });

  factory Advertisement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Advertisement(
      id: doc.id,
      imageUrl: data['image_url'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      sendNotification: data['send_notification'] ?? true,
      notificationSent: data['notification_sent'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image_url': imageUrl,
      'title': title,
      'description': description,
      'send_notification': sendNotification,
      'notification_sent': notificationSent,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
