import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/account_model.dart';

class UserModel {
  String id;
  String username;
  String email;
  List<Account> accounts;

  UserModel({
    required this.id,
    this.username = '',
    this.email = '',
    List<Account>? accounts,
  }) : accounts = accounts ?? [Account(name: 'main', balance: 0.0)];

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    var accountList = (doc['accounts'] as List<dynamic>?)
            ?.map((account) => Account.fromMap(account))
            .toList() ??
        [Account(name: 'main', balance: 0.0)];

    return UserModel(
      id: doc.id,
      username: doc['username'] ?? '',
      email: doc['email'],
      accounts: accountList,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'username': username,
      'email': email,
      'accounts': accounts.map((account) => account.toMap()).toList(),
    };
  }

  double get totalBalance {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }
}
