import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String id;
  String userId;
  double amount;
  String type;
  String category;
  Timestamp date;
  bool havePhotos;
  String? details;
  String account;

  TransactionModel({
    required this.id,
    this.userId = '',
    this.amount = 0.0,
    this.type = '',
    this.category = '',
    Timestamp? date,
    this.havePhotos = false,
    this.details,
    this.account = 'main',
  }) : date = date ?? Timestamp.now();

  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    return TransactionModel(
      id: doc.id,
      userId: doc['userId'] ?? '',
      amount: doc['amount']?.toDouble() ?? 0.0,
      type: doc['type'] ?? '',
      category: doc['category'] ?? '',
      date: doc['date'] ?? Timestamp.now(),
      havePhotos: doc['havePhotos'] ?? false,
      details: doc['details'],
      account: doc['account'] ?? 'main',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'havePhotos': havePhotos,
      'details': details,
      'account': account,
    };
  }
}
