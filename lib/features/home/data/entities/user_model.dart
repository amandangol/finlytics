import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models.dart';

class UserModel {
  String username;
  String email;
  List<Account> accounts;
  bool haveReminders;

  UserModel({
    required this.username,
    required this.email,
    required this.accounts,
    this.haveReminders = false,
  });

  double get totalBalance {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      accounts: (data['accounts'] as List?)
              ?.map((accountData) => Account.fromMap(accountData))
              .toList() ??
          [],
      haveReminders: data['haveReminders'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'accounts': accounts.map((account) => account.toMap()).toList(),
      'haveReminders': haveReminders,
    };
  }
}
