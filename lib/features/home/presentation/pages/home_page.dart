import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../models/account_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../../models/user_model.dart';
import '../../../gemini_chat_ai/presentation/screens/gemini_chat_ai.dart';
import '../../../profile/screens/profile_page.dart';
import '../../../transaction/presentation/pages/transaction_list/transaction_list_page.dart';
import '../../../transaction/data/transaction_service.dart';
import '../../../auth/services/user_service.dart';
import '../widgets/custom_navigation_bar.dart';
import 'home_content.dart';
import '../widgets/accounts_dialog.dart';
import '../widgets/username_input_dialog.dart';
import '../../../transaction/presentation/pages/add_transaction/add_transaction_page.dart';
import '../../../financial_insights/presentation/pages/financial_insights.dart';
// Import the HomeAppBar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final UserService _userService = UserService();
  final TransactionService _transactionService = TransactionService();
  int _selectedIndex = 0;
  bool _isLoadingTransactions = false;
  bool _isInitializing = true;

  User? user;
  UserModel? userModel;
  Account? selectedAccount;

  // Variables for overview section
  String _selectedPeriod = 'Overall'; // Default period
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  Map<String, double> expenseByCategory = {};
  bool totalDataFetched = false;
  List<TransactionModel> recentTransactions = [];
  List<TransactionModel> allTransactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isInitializing = true);

      user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Set language code once
      await FirebaseAuth.instance
          .setLanguageCode(Platform.localeName.split('_')[0]);

      // Fetch user data
      UserModel? fetchedUserModel = await _userService.getUserById(user!.uid);

      if (fetchedUserModel == null) {
        // Create user document if not exists
        await _createUserDocument(user!.uid);
        fetchedUserModel = await _userService.getUserById(user!.uid);
      }

      if (fetchedUserModel != null) {
        setState(() {
          userModel = fetchedUserModel;
          _isInitializing = false;
        });

        // Prompt for username if empty
        if (userModel!.username.isEmpty) {
          await promptUsernameInput(user!.uid);
        }

        // Fetch initial transactions
        await _fetchTransactionsForPeriod(_selectedPeriod);
      }
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Stream<DocumentSnapshot> _getUserStream() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
  }

  Future<void> getUser() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      UserModel? fetchedUserModel = await _userService.getUserById(user!.uid);

      if (fetchedUserModel != null) {
        setState(() {
          userModel = fetchedUserModel;
        });

        if (userModel!.username.isEmpty) {
          await promptUsernameInput(user!.uid);
        }

        // Fetch data for the default period (This Week)
        await _fetchTransactionsForPeriod(_selectedPeriod);
      } else {
        await _createUserDocument(user!.uid);
        await getUser();
      }
    }
  }

  Future<void> _createUserDocument(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'username': '',
      'email': user?.email,
      'accounts': [], // Start with an empty accounts list
    });
  }

  Future<void> promptUsernameInput(String userId) async {
    String? username = await UsernameBottomSheet.show(context, userId) ?? "";

    if (username.isNotEmpty) {
      await _userService.updateUsername(userId, username);
      await getUser();

      // Immediately prompt for initial account after username is set
      if (userModel != null && userModel!.accounts.isEmpty) {
        await _showInitialAccountBottomSheet(userId);
      }
    }
  }

  Future<void> _showInitialAccountBottomSheet(String userId) async {
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController initialBalanceController =
        TextEditingController();

    // Store context reference before async operations
    final BuildContext currentContext = context;

    try {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: currentContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Setup Your First Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Don\'t worry, you can always add, edit, or delete accounts later from the home page.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: accountNameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., Main Account, Savings, Checking',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: initialBalanceController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: 'Enter your starting balance',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String name = accountNameController.text.trim();
                    String balanceText = initialBalanceController.text.trim();

                    // Validate inputs
                    if (name.isEmpty) {
                      Navigator.of(context)
                          .pop({'error': 'Please enter an account name'});
                      return;
                    }

                    double? initialBalance = double.tryParse(balanceText);
                    if (initialBalance == null) {
                      Navigator.of(context)
                          .pop({'error': 'Please enter a valid balance'});
                      return;
                    }

                    Navigator.of(context).pop({
                      'name': name,
                      'balance': initialBalance,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDarkColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop({'skipped': true}),
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      // Handle the result
      if (result != null && mounted) {
        if (result.containsKey('error')) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
          return;
        }

        if (result.containsKey('skipped')) {
          return;
        }

        if (result.containsKey('name') && result.containsKey('balance')) {
          Account newAccount = Account(
            name: result['name'],
            balance: result['balance'],
            initialBalance: result['balance'],
          );

          await _userService.addAccount(userId, newAccount);

          // Refresh user data
          await getUser();

          if (mounted) {
            ErrorUtils.showSnackBar(
              context: context,
              message: 'Account "${result['name']}" created successfully!',
              color: AppTheme.successColor,
              icon: Icons.check_circle_outline,
            );
          }
        }
      }
    } finally {
      accountNameController.dispose();
      initialBalanceController.dispose();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _renameAccount(String accountName) {
    // Prompt for the new account name
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Account: $accountName'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter new account name',
          ),
          onSubmitted: (newName) async {
            // Close the dialog
            Navigator.of(context).pop();

            // Check if the new name is empty
            if (newName.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account name cannot be empty')),
              );
              return;
            }

            try {
              // Proceed with renaming
              await _userService.renameAccount(user!.uid, accountName, newName);

              // Refresh user data after renaming
              await getUser();

              // If the currently selected account was renamed, update the selection
              if (selectedAccount?.name == accountName) {
                setState(() {
                  selectedAccount =
                      Account(name: newName, balance: selectedAccount!.balance);
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account renamed to $newName')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to rename account: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(String accountName) async {
    // Prevent deletion if it's the last account
    if (userModel!.accounts.length <= 1) {
      ErrorUtils.showSnackBar(
          color: Colors.red,
          icon: Icons.error_outline,
          context: context,
          message: 'Cannot delete the last account');

      return;
    }

    // Prevent deleting the currently selected account
    if (selectedAccount?.name == accountName) {
      ErrorUtils.showSnackBar(
          context: context,
          color: Colors.red,
          icon: Icons.error_outline,
          message: 'Cannot delete the currently selected account');
      return;
    }

    // Check if the account has any associated transactions
    bool hasTransactions =
        await _userService.checkAccountHasTransactions(user!.uid, accountName);

    if (hasTransactions) {
      // Prompt user to confirm deletion of account with transactions
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Delete Account'),
          content: const Text(
              'This account has existing transactions. Are you sure you want to delete it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmDelete != true) return;
    }

    try {
      // Delete the account
      await _userService.deleteAccount(user!.uid, accountName);

      // Update the local state
      await getUser();

      // Reset selected account if it was the deleted one
      if (selectedAccount?.name == accountName) {
        setState(() {
          selectedAccount = null;
        });
      }

      ErrorUtils.showSnackBar(
          color: Colors.black,
          icon: Icons.check_circle_outline,
          context: context,
          message: 'Account $accountName deleted');
    } catch (e) {
      ErrorUtils.showSnackBar(
          color: Colors.red,
          icon: Icons.error_outline,
          context: context,
          message: 'Failed to delete account $e');
    }
  }

  void _showAccountsDialog() async {
    // Ensure user model is loaded
    if (userModel == null) {
      await getUser(); // Force fetch user data
    }

    // Check again after fetching
    if (userModel != null) {
      if (userModel!.accounts.isEmpty) {
        // If no accounts exist, show the initial account creation bottom sheet
        await _showInitialAccountBottomSheet(user!.uid);
      } else {
        // Show accounts dialog if accounts exist
        showDialog(
          context: context,
          builder: (context) => AccountsDialog(
            accounts: userModel!.accounts,
            onAddAccount: _addAccount,
            onUpdateBalance: _updateBalance,
            onSelectAccount: _selectAccount,
            onSelectTotalBalance: _selectTotalBalance,
            onRenameAccount: _renameAccount,
            onDeleteAccount: _deleteAccount,
            selectedAccount: selectedAccount,
          ),
        );
      }
    } else {
      // Fallback error handling
      ErrorUtils.showSnackBar(
        color: Colors.red,
        icon: Icons.error_outline,
        context: context,
        message: 'Unable to load user information. Please try again.',
      );
    }
  }

  Future<void> _addAccount(String name, double balance) async {
    bool accountExists = userModel!.accounts
        .any((account) => account.name.toLowerCase() == name.toLowerCase());

    if (accountExists) {
      ErrorUtils.showSnackBar(
          context: context,
          color: Colors.red,
          icon: Icons.error_outline,
          message: 'Account with the same name already exists!');
      return;
    }

    Account newAccount = Account(name: name, balance: balance);
    await _userService.addAccount(user!.uid, newAccount);
    await getUser();
  }

  Future<void> _updateBalance(String accountName, double newBalance) async {
    var account =
        userModel!.accounts.firstWhere((acc) => acc.name == accountName);
    account.balance = newBalance;

    await _userService.updateAccountBalance(user!.uid, account);
    await getUser();
  }

  void _selectAccount(Account account) {
    setState(() {
      selectedAccount = account;
    });
    Navigator.of(context).pop();
  }

  void _selectTotalBalance() {
    setState(() {
      selectedAccount = null;
    });
    Navigator.of(context).pop();
  }

  Future<void> _fetchTransactionsForPeriod(String period) async {
    if (user == null) return;

    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
    DateTime endDate = DateTime.now();

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'This Week':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Overall':
        startDate = DateTime(1970);
        endDate = DateTime.now();
        break;
      default:
        startDate = startDate.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
    }

    try {
      List<TransactionModel> transactions =
          await _transactionService.fetchTransactionsByPeriod(
        user!.uid,
        startDate: startDate,
        endDate: endDate,
      );

      // Reset these values before calculating
      setState(() {
        totalIncome = 0.0;
        totalExpense = 0.0;
        expenseByCategory.clear();
        recentTransactions.clear();
      });

      _calculateOverviewData(transactions);

      if (period == 'Overall') {
        setState(() {
          allTransactions = transactions.toList();
          totalDataFetched = true;
        });
      }

      // Fetch the recent transactions for the selected period
      setState(() {
        recentTransactions = transactions.take(5).toList();
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch transactions: $e')),
      );
    }
  }

  void _calculateOverviewData(List<TransactionModel> transactions) {
    double income = 0.0;
    double expense = 0.0;
    Map<String, double> categoryExpenses = {};

    for (var transaction in transactions) {
      if (transaction.type == 'Income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
        categoryExpenses.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    setState(() {
      totalIncome = income;
      totalExpense = expense;
      expenseByCategory = categoryExpenses;
    });
  }

  Future<void> _initializeTransactions() async {
    if (allTransactions.isEmpty) {
      _selectedPeriod = "Overall";
      await _fetchTransactionsForPeriod("Overall");
    }
  }

  void _updateTransactionInState(TransactionModel updatedTransaction) {
    setState(() {
      // Update in recent transactions
      int recentIndex =
          recentTransactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (recentIndex != -1) {
        recentTransactions[recentIndex] = updatedTransaction;
      }

      // Update in all transactions
      int allIndex =
          allTransactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (allIndex != -1) {
        allTransactions[allIndex] = updatedTransaction;
      }

      // Recalculate overview data
      _calculateOverviewData(
          allTransactions.isNotEmpty ? allTransactions : recentTransactions);
    });
  }

  void _deleteTransactionFromDetailPage(String transactionId) {
    recentTransactions
        .removeWhere((transaction) => transaction.id == transactionId);
    allTransactions
        .removeWhere((transaction) => transaction.id == transactionId);
    _calculateOverviewData(
        allTransactions.isNotEmpty ? allTransactions : recentTransactions);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (canPop) {
        if (!canPop) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: _isInitializing
            ? const Center(
                child: SpinKitThreeBounce(
                  color: AppTheme.primaryDarkColor,
                  size: 20.0,
                ),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: _getUserStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  // Use the current state for rendering
                  return _buildBody();
                },
              ),
        bottomNavigationBar: SleekNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _selectedIndex == 0 ? _buildHomeContent() : Container(),
        _selectedIndex == 1 ? _buildChartsContent() : Container(),
        _selectedIndex == 2
            ? AddTransactionPage(userModel: userModel!)
            : Container(),
        _selectedIndex == 3 ? const GeminiChatAiPage() : Container(),
        ProfilePage(
          user: userModel!,
        )
      ],
    );
  }

  void _deleteTransactionFromState(String transactionId) {
    setState(() {
      // Remove from recent transactions
      recentTransactions
          .removeWhere((transaction) => transaction.id == transactionId);

      // Also remove from all transactions if it exists
      allTransactions
          .removeWhere((transaction) => transaction.id == transactionId);
    });
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Expanded(
          child: HomeContent(
            userModel: userModel!,
            selectedAccount: selectedAccount,
            selectedPeriod: _selectedPeriod,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            expenseByCategory: expenseByCategory,
            recentTransactions: recentTransactions,
            onShowAccountsDialog: _showAccountsDialog,
            isLoading: _isLoadingTransactions,
            onPeriodChanged: (period) async {
              // Set loading state to true before fetching
              setState(() {
                _isLoadingTransactions = true;
                _selectedPeriod = period;
                // Reset some state to ensure fresh data
                totalIncome = 0.0;
                totalExpense = 0.0;
                expenseByCategory.clear();
                recentTransactions.clear();
              });

              try {
                // Fetch transactions for the new period
                await _fetchTransactionsForPeriod(period);
              } catch (e) {
                // Handle any errors
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load transactions: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                // Set loading state to false after fetching
                setState(() {
                  _isLoadingTransactions = false;
                });
              }
            },
            onViewAllTransactions: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TransactionListPage(
                    transactions: allTransactions.isEmpty
                        ? recentTransactions
                        : allTransactions,
                    userId: user!.uid,
                    onTransactionDeleted: _deleteTransactionFromDetailPage,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartsContent() {
    return FinancialInsightsPage(
      allTransactions: allTransactions,
      userId: user!.uid,
      userModel: userModel!,
    );
  }
}
