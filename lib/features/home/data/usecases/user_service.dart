import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/account_model.dart';
import '../../../../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return UserModel.fromDocument(userDoc);
    }
    return null;
  }

  Future<void> updateUsername(String userId, String username) async {
    await _firestore.collection('users').doc(userId).update({
      'username': username,
    });
  }

  Future<void> addAccount(String userId, Account account) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.update({
      'accounts': FieldValue.arrayUnion([account.toMap()]),
    });
  }

  Future<void> updateAccountBalance(String userId, Account account) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDoc.get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

    List<dynamic> accounts = userData['accounts'] ?? [];

    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i]['name'] == account.name) {
        accounts[i]['balance'] = account.balance;
        break;
      }
    }

    await userDoc.update({
      'accounts': accounts,
    });
  }
}
