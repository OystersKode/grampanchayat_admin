import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String categoryColor;
  final String headerImageUrl;
  final List<String> relatedImageUrls;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isPublished;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.category = '',
    this.categoryColor = '#8B0000',
    this.headerImageUrl = '',
    this.relatedImageUrls = const [],
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.scheduledAt,
    this.isPublished = true,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      categoryColor: data['category_color'] ?? '#8B0000',
      headerImageUrl: data['header_image_url'] ?? '',
      relatedImageUrls: List<String>.from(data['related_image_urls'] ?? []),
      createdBy: data['created_by'] ?? '',
      createdByName: data['created_by_name'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledAt: (data['scheduled_at'] as Timestamp?)?.toDate(),
      isPublished: data['is_published'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'category_color': categoryColor,
      'header_image_url': headerImageUrl,
      'related_image_urls': relatedImageUrls,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': Timestamp.fromDate(createdAt),
      'scheduled_at': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'is_published': isPublished,
    };
  }
}
