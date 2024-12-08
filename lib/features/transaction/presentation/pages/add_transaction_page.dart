import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/constants/app_colors.dart';
import '../../../../../../../core/utils/category_helper.dart';
import '../../../../../../../models.dart';

class AddTransactionPage extends StatefulWidget {
  final UserModel userModel;

  const AddTransactionPage({super.key, required this.userModel});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  final _dateController = TextEditingController();

  String _selectedType = 'Expense';
  String _selectedCategory = 'Bills';
  String _selectedAccount = 'Main';
  final List<File> _selectedPhotos = [];
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
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
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedPhotos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Limit Reached: You can add up to 3 images per transaction.',
            style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        path.join(
          path.dirname(pickedFile.path),
          '${path.basenameWithoutExtension(pickedFile.path)}_compressed.jpg',
        ),
        quality: 70,
      );

      if (compressedImage != null) {
        setState(() {
          _selectedPhotos.add(File(compressedImage.path));
        });
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('transaction_photos/${path.basename(image.path)}');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final double amount = double.parse(_amountController.text);
    final String details = _detailsController.text;

    if (_selectedType == 'Expense') {
      final selectedAccount = widget.userModel.accounts
          .firstWhere((account) => account.name == _selectedAccount);
      if (selectedAccount.balance < amount) {
        _showAlertDialog('Insufficient Balance',
            'The selected account has insufficient balance for this expense. Please add balance or select another account.');
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    List<String> photoUrls = [];
    for (var photo in _selectedPhotos) {
      final photoUrl = await _uploadImage(photo);
      photoUrls.add(photoUrl);
    }

    final transaction = TransactionModel(
      id: '',
      userId: widget.userModel.id,
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      details: details,
      account: _selectedAccount,
      havePhotos: photoUrls.isNotEmpty,
      date: Timestamp.fromDate(_selectedDate),
    );

    final transactionRef = await FirebaseFirestore.instance
        .collection('transactions')
        .add(transaction.toDocument());
    await _addPhotos(transactionRef.id, photoUrls);

    if (_selectedType == 'Expense') {
      _updateAccountBalance(_selectedAccount, -amount);
    } else {
      _updateAccountBalance(_selectedAccount, amount);
    }

    Navigator.of(context)
        .pop(true); // Return true to indicate a successful transaction
  }

  Future<void> _addPhotos(String transactionId, List<String> photoUrls) async {
    for (var url in photoUrls) {
      final photo = PhotoModel(
        id: '',
        userId: widget.userModel.id,
        transactionId: transactionId,
        imageUrl: url,
      );
      await FirebaseFirestore.instance
          .collection('photos')
          .add(photo.toDocument());
    }
  }

  Future<void> _updateAccountBalance(String accountName, double amount) async {
    final account =
        widget.userModel.accounts.firstWhere((acc) => acc.name == accountName);
    account.balance += amount;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.id)
        .update({
      'accounts':
          widget.userModel.accounts.map((account) => account.toMap()).toList(),
    });
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: Text(content),
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(color: AppTheme.primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: AppTheme.textTheme.displayMedium
              ?.copyWith(color: AppTheme.lightTextColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isSubmitting
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAmountInput(),
                      const SizedBox(height: 16),
                      _buildDetailsInput(),
                      const SizedBox(height: 16),
                      _buildDateInput(),
                      const SizedBox(height: 16),
                      _buildTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(),
                      const SizedBox(height: 16),
                      _buildPhotoSection(),
                      const SizedBox(height: 16),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Amount',
        labelStyle: AppTheme.textTheme.bodyMedium,
        prefixIcon: Icon(Icons.currency_rupee, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      style: AppTheme.textTheme.bodyLarge,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        return null;
      },
    );
  }

  Widget _buildDetailsInput() {
    return TextFormField(
      controller: _detailsController,
      decoration: InputDecoration(
        labelText: 'Details',
        labelStyle: AppTheme.textTheme.bodyMedium,
        prefixIcon: Icon(Icons.notes, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      maxLines: 2,
      style: AppTheme.textTheme.bodyLarge,
      validator: (value) {
        if (value != null && value.length > 50) {
          return 'Details should be less than 50 words';
        }
        return null;
      },
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date',
        labelStyle: AppTheme.textTheme.bodyMedium,
        prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      readOnly: true,
      onTap: _pickDate,
      style: AppTheme.textTheme.bodyLarge,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Type',
        labelStyle: AppTheme.textTheme.bodyMedium,
        prefixIcon: Icon(Icons.swap_vert, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      value: _selectedType,
      items: ['Expense', 'Income'].map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: AppTheme.textTheme.bodyLarge,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedType = newValue!;
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    final List<String> categories = CategoryHelper.getAllCategories();

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: AppTheme.textTheme.bodyMedium,
        prefixIcon: Icon(Icons.category, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      value: _selectedCategory,
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Icon(
                CategoryHelper.getCategoryIcon(category),
                color: CategoryHelper.getCategoryColor(category),
              ),
              const SizedBox(width: 10),
              Text(
                category,
                style: AppTheme.textTheme.bodyLarge,
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
      },
    );
  }

  Widget _buildAccountDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Account',
        labelStyle: AppTheme.textTheme.bodyMedium,
        prefixIcon:
            Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      value: _selectedAccount,
      items: widget.userModel.accounts.map((Account account) {
        return DropdownMenuItem<String>(
          value: account.name,
          child: Text(
            account.name,
            style: AppTheme.textTheme.bodyLarge,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedAccount = newValue!;
        });
      },
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add Photos",
          style: AppTheme.textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maximum 3 photos',
              style: AppTheme.textTheme.bodyMedium,
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text('Camera', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library, color: Colors.white),
              label: Text('Gallery', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedPhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Image.file(
                        _selectedPhotos[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPhotos.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle:
            AppTheme.textTheme.displaySmall?.copyWith(color: Colors.white),
      ),
      child: Text(
        'Submit Transaction',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
