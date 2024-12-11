import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/account_model.dart';

class UserModel {
  String id;
  String username;
  String email;
  List<Account> accounts;
  String? profileImageUrl;

  UserModel({
    required this.id,
    this.username = '',
    this.email = '',
    this.profileImageUrl,
    List<Account>? accounts,
  }) : accounts = accounts ?? [Account(name: 'main', balance: 0.0)];

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    // Safely cast to map and handle potential null values
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ArgumentError('Document data is null');
    }

    // Handle accounts parsing with null safety
    List<Account> accountList;
    try {
      accountList = data['accounts'] != null
          ? (data['accounts'] as List)
              .map((account) => Account.fromMap(account))
              .toList()
          : [Account(name: 'main', balance: 0.0)];
    } catch (e) {
      print('Error parsing accounts: $e');
      accountList = [Account(name: 'main', balance: 0.0)];
    }

    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      accounts: accountList,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'accounts': accounts.map((account) => account.toMap()).toList(),
    };
  }

  double get totalBalance {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get totalInitialBalance {
    return accounts.fold(0.0, (sum, account) => sum + account.initialBalance);
  }

  // Method to update profile image URL
  UserModel copyWith({
    String? username,
    String? email,
    String? profileImageUrl,
    List<Account>? accounts,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      accounts: accounts ?? this.accounts,
    );
  }
}
