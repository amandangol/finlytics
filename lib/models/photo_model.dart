import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  String id;
  String userId;
  String transactionId;
  String imageUrl;

  PhotoModel({
    required this.id,
    this.userId = '',
    this.transactionId = '',
    this.imageUrl = '',
  });

  factory PhotoModel.fromDocument(DocumentSnapshot doc) {
    return PhotoModel(
      id: doc.id,
      userId: doc['userId'] ?? '',
      transactionId: doc['transactionId'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'transactionId': transactionId,
      'imageUrl': imageUrl,
    };
  }
}
