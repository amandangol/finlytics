import 'package:expense_tracker/core/common/custom_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/category_helper.dart';
import '../../../../../models.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsPage({super.key, required this.transaction});

  Future<List<PhotoModel>> _fetchTransactionPhotos(
      String userId, String transactionId) async {
    if (!transaction.havePhotos) {
      return [];
    }
    QuerySnapshot photoQuery = await FirebaseFirestore.instance
        .collection('photos')
        .where('userId', isEqualTo: userId)
        .where('transactionId', isEqualTo: transactionId)
        .get();

    return photoQuery.docs.map((doc) => PhotoModel.fromDocument(doc)).toList();
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('Delete Transaction',
              style: TextStyle(
                  color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
          content: const Text(
              'Deleting this transaction can cause inconsistency to the respective account, are you sure you want to delete?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFFEF6C06))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppTheme.errorColor)),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(transaction.userId)
          .get();
      UserModel userModel = UserModel.fromDocument(userSnapshot);

      double adjustedAmount = transaction.type == 'Income'
          ? -transaction.amount
          : transaction.amount;

      // Update the account balance
      await _updateAccountBalance(
          userModel, transaction.account, adjustedAmount);

      // Check if the transaction has associated photos
      if (transaction.havePhotos) {
        QuerySnapshot photoQuery = await FirebaseFirestore.instance
            .collection('photos')
            .where('userId', isEqualTo: transaction.userId)
            .where('transactionId', isEqualTo: transaction.id)
            .get();

        for (QueryDocumentSnapshot doc in photoQuery.docs) {
          String photoUrl = doc['imageUrl'];

          Reference photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
          await photoRef.delete();

          // Delete the photo entry from Firestore
          await FirebaseFirestore.instance
              .collection('photos')
              .doc(doc.id)
              .delete();
        }
      }

      // Delete the transaction from Firestore
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .delete();

      Navigator.of(context).pop(true);
    }
  }

  Future<void> _updateAccountBalance(
      UserModel userModel, String accountName, double amount) async {
    final account =
        userModel.accounts.firstWhere((acc) => acc.name == accountName);

    account.balance += amount;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.id)
        .update({
      'accounts': userModel.accounts.map((account) => account.toMap()).toList(),
    });
  }

  Future<void> _editTransaction(BuildContext context) async {
    final TextEditingController detailsController =
        TextEditingController(text: transaction.details);
    final TextEditingController dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(transaction.date.toDate()));

    // Use the expanded category list from CategoryHelper
    final List<String> categories = CategoryHelper.getAllCategories();

    String selectedCategory = transaction.category;

    bool edited = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.edit,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Transaction',
                    style: AppTheme.textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: AppTheme.textTheme.bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      CategoryHelper.getCategoryIcon(category),
                                      color: CategoryHelper.getCategoryColor(
                                          category),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(category),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: detailsController,
                      decoration: InputDecoration(
                        labelText: 'Details',
                        labelStyle: AppTheme.textTheme.bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: AppTheme.textTheme.bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: transaction.date.toDate(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppTheme.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppTheme.darkTextColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(pickedDate);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.mutedTextColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newDetails = detailsController.text;
                    DateTime newDate =
                        DateFormat('dd/MM/yyyy').parse(dateController.text);

                    await FirebaseFirestore.instance
                        .collection('transactions')
                        .doc(transaction.id)
                        .update({
                      'category': selectedCategory,
                      'details': newDetails,
                      'date': Timestamp.fromDate(newDate),
                    });

                    Navigator.of(context).pop(true);
                  },
                  style: AppTheme.elevatedButtonStyle,
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (edited) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      // Format the current date and time
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
      final filePath =
          "/storage/emulated/0/DCIM/TrackUrSpends/transaction_photo_$formattedDate.jpg";

      // Download the file
      await Dio().download(url, filePath);

      // Notify the user of the successful download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded to $filePath')),
      );
    } catch (e) {
      // Handle any errors during the download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Transaction Details"),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _buildTransactionSummaryCard(),
              const SizedBox(height: 16),
              _buildDetailSection(),
              const SizedBox(height: 16),
              _buildPhotosSection(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: transaction.type == 'Expense'
              ? [AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.7)]
              : [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                CategoryHelper.getCategoryIcon(transaction.category),
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: AppTheme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    transaction.type,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${transaction.amount.toStringAsFixed(2)}',
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              "Date",
              DateFormat('dd MMM yyyy').format(transaction.date.toDate()),
            ),
            const Divider(height: 24, thickness: 0.5),
            _buildDetailRow("Account", transaction.account),
            const Divider(height: 24, thickness: 0.5),
            _buildDetailRow(
              "Details",
              transaction.details ?? "No additional details",
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.mutedTextColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.darkTextColor,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attached Photos",
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontSize: 18,
            color: AppTheme.darkTextColor,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<PhotoModel>>(
          future: _fetchTransactionPhotos(transaction.userId, transaction.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No photos attached',
                  style: AppTheme.textTheme.bodyMedium,
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final photo = snapshot.data![index];
                return GestureDetector(
                  onTap: () => _downloadImage(context, photo.imageUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(photo.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _editTransaction(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: AppTheme.elevatedButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(AppTheme.secondaryColor),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _deleteTransaction(context),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: AppTheme.elevatedButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(AppTheme.errorColor),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
