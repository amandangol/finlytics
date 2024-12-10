import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/user_model.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Delete all user-related data
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete transactions
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      // Delete transactions
      for (var doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete photos from Firestore and Storage
      final photosQuery = await _firestore
          .collection('photos')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in photosQuery.docs) {
        final photoUrl = doc['imageUrl'] as String?;
        if (photoUrl != null) {
          await _storage.refFromURL(photoUrl).delete();
        }
        batch.delete(doc.reference);
      }

      // Commit batch operations
      await batch.commit();

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user data: $e');
    }
  }

  // Update user profile image
  Future<UserModel> updateProfileImage(
      {required String userId, required File imageFile}) async {
    try {
      // Generate a unique filename
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // Reference to storage location
      final storageRef = _storage.ref().child('profile_images/$fileName');

      // Upload image
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore document
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({'profileImageUrl': downloadUrl});

      // Fetch updated user document
      final updatedDoc = await userRef.get();
      return UserModel.fromDocument(updatedDoc);
    } catch (e) {
      throw Exception('Error updating profile image: $e');
    }
  }

  // Update username
  Future<void> updateUsername(String userId, String newUsername) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
      });
    } catch (e) {
      throw Exception('Error updating username: $e');
    }
  }

  // Reset user accounts and balance
  Future<void> resetUserAccounts(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Get current user document
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist.");
      }

      UserModel userModel = UserModel.fromDocument(userDoc);

      // Delete all accounts except the main one and set the balance of the main account to 0
      if (userModel.accounts.isNotEmpty) {
        userModel.accounts.removeWhere((account) => account.name != 'Main');
        if (userModel.accounts.isNotEmpty) {
          userModel.accounts[0].balance = 0;
        }
      }

      // Update user document
      await userRef.update({
        'accounts':
            userModel.accounts.map((account) => account.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Error resetting user accounts: $e');
    }
  }
}
