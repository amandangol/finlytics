import 'package:expense_tracker/core/common/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/error_utils.dart';
import '../../../../../models/photo_model.dart';
import '../../../../../models/transaction_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../home/presentation/pages/home_page.dart';
import 'widgets/account_dropdown_widget.dart';
import 'widgets/amount_input_widget.dart';
import 'widgets/category_dropdown_widget.dart';
import 'widgets/date_input_widget.dart';
import 'widgets/details_input_widget.dart';
import 'widgets/photo_section_widget.dart';
import 'widgets/submit_button.dart';
import 'widgets/type_dropdown_widget.dart';
import 'widgets/common_input_decoration.dart';

class AddTransactionPage extends StatefulWidget {
  final UserModel userModel;

  const AddTransactionPage({super.key, required this.userModel});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  final _dateController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedType = 'Expense';
  String _selectedCategory = 'Bills';
  String _selectedAccount = 'Main';
  final List<File> _selectedPhotos = [];
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Create slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ),
    );

    // Start the animation
    _animationController.forward();

    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    // Set default account if available
    if (widget.userModel.accounts.isNotEmpty) {
      _selectedAccount = widget.userModel.accounts.first.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime initialDate) async {
    final currentTheme = Theme.of(context).brightness;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: currentTheme == Brightness.light
              ? AppTheme.lightTheme.copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppTheme.primaryColor,
                    onPrimary: AppTheme.lightTextColor,
                    surface: AppTheme.surfaceColor,
                    onSurface: AppTheme.darkTextColor,
                  ),
                )
              : AppTheme.darkTheme.copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.primaryColor,
                    onPrimary: AppTheme.lightTextColor,
                    surface: AppTheme.cardColor,
                    onSurface: AppTheme.lightTextColor,
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

    // Image picking logic remains the same as in the original implementation
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedPhotos.add(File(pickedFile.path));
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child(
        'transaction_photos/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _submitTransaction() async {
    try {
      if (!_formKey.currentState!.validate()) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final double amount = double.parse(_amountController.text);
      final String details = _detailsController.text;

      // Balance check for expenses
      if (_selectedType == 'Expense') {
        final selectedAccount = widget.userModel.accounts
            .firstWhere((account) => account.name == _selectedAccount);
        if (selectedAccount.balance < amount) {
          ErrorUtils.showSnackBar(
            context: context,
            color: AppTheme.errorColor,
            icon: Icons.error_outline,
            message:
                'Insufficient Balance. Please add balance or select another account.',
            isError: true,
          );
          return;
        }
      }

      setState(() {
        _isSubmitting = true;
      });
      // Upload photos
      List<String> photoUrls = [];
      for (var photo in _selectedPhotos) {
        final photoUrl = await _uploadImage(photo);
        photoUrls.add(photoUrl);
      }

      // Create transaction
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

      // Save transaction to Firestore
      final transactionRef = await FirebaseFirestore.instance
          .collection('transactions')
          .add(transaction.toDocument());

      // Save photos
      await _addPhotos(transactionRef.id, photoUrls);

      // Update account balance
      if (_selectedType == 'Expense') {
        _updateAccountBalance(_selectedAccount, -amount);
      } else {
        _updateAccountBalance(_selectedAccount, amount);
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      ErrorUtils.showSnackBar(
        context: context,
        color: AppTheme.successColor,
        icon: Icons.check_circle_outline,
        message: 'Transaction added successfully!',
        isError: false,
        onVisible: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ErrorUtils.showSnackBar(
        context: context,
        message: 'Failed to submit transaction: ${e.toString()}',
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Add Transaction",
      ),
      body: _isSubmitting
          ? Center(
              child: ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: const Center(
                    child: SpinKitThreeBounce(
                      color: AppTheme.primaryDarkColor,
                      size: 20.0,
                    ),
                  )),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 230, 236, 241),
                        Color.fromARGB(255, 220, 239, 225),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AmountInputWidget(
                                controller: _amountController,
                                decoration: getCommonInputDecoration(context,
                                    labelText: 'Amount',
                                    prefixIcon: Icons.money),
                              ),
                              const SizedBox(height: 16),
                              DetailsInputWidget(
                                controller: _detailsController,
                                decoration: getCommonInputDecoration(context,
                                    labelText: 'Details',
                                    prefixIcon: Icons.notes),
                              ),
                              const SizedBox(height: 16),
                              DateInputWidget(
                                controller: _dateController,
                                onTap: () => _pickDate(_selectedDate),
                                decoration: getCommonInputDecoration(context,
                                    labelText: 'Date',
                                    prefixIcon: Icons.calendar_today),
                              ),
                              const SizedBox(height: 16),
                              TypeDropdownWidget(
                                value: _selectedType,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedType = newValue!;
                                  });
                                },
                                decoration: getCommonInputDecoration(context,
                                    labelText: 'Type',
                                    prefixIcon: Icons.swap_vert_sharp),
                              ),
                              const SizedBox(height: 16),
                              CategoryDropdownWidget(
                                value: _selectedCategory,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedCategory = newValue!;
                                  });
                                },
                                decoration: getCommonInputDecoration(context,
                                    labelText: 'Category',
                                    prefixIcon: Icons.category),
                              ),
                              const SizedBox(height: 16),
                              AccountDropdownWidget(
                                accounts: widget.userModel.accounts,
                                value: _selectedAccount,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedAccount = newValue!;
                                  });
                                },
                                decoration: getCommonInputDecoration(context,
                                    labelText: 'Account',
                                    prefixIcon: Icons.account_balance_wallet),
                              ),
                              const SizedBox(height: 16),
                              PhotoSectionWidget(
                                selectedPhotos: _selectedPhotos,
                                onCameraPressed: () =>
                                    _pickImage(ImageSource.camera),
                                onGalleryPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                onPhotoRemoved: (index) {
                                  setState(() {
                                    _selectedPhotos.removeAt(index);
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _fadeAnimation.value,
                                    child: child,
                                  );
                                },
                                child: SubmitButton(
                                  onPressed: _submitTransaction,
                                  child: Text(
                                    'Submit Transaction',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppTheme.lightTextColor,
                                        ),
                                  ),
                                ),
                              )
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
