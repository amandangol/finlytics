import 'package:expense_tracker/core/utils/error_utils.dart';
import 'package:expense_tracker/features/home/presentation/widgets/custom_navigation_bar.dart';
import 'package:expense_tracker/features/gemini_chat_ai/presentation/screens/gemini_chat_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/account_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../../models/user_model.dart';
import '../../../profile/screens/profile_page.dart';
import '../../../transaction/presentation/pages/transaction_list/transaction_list_page.dart';
import '../../../transaction/data/transaction_service.dart';
import '../../../auth/services/user_service.dart';
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
      user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        UserModel? fetchedUserModel = await _userService.getUserById(user!.uid);

        if (fetchedUserModel != null) {
          setState(() {
            userModel = fetchedUserModel;
          });

          // Prompt for username if empty
          if (userModel!.username.isEmpty) {
            await promptUsernameInput(user!.uid);
          }

          // Fetch transactions for the default period
          await _fetchTransactionsForPeriod(_selectedPeriod);
        } else {
          // Create user document if not exists
          await _createUserDocument(user!.uid);
        }
      }
    } catch (e) {
      print('Error initializing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      'accounts': [Account(name: 'Main', balance: 0.0).toMap()],
    });
  }

  Future<void> _refreshData() async {
    try {
      // Fetch user data again
      await getUser();

      // Refresh transactions for the current period
      await _fetchTransactionsForPeriod(_selectedPeriod);
    } catch (e) {
      // Handle any errors during refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> promptUsernameInput(String userId) async {
    String? username = await UsernameBottomSheet.show(context, userId) ?? "";

    if (username.isNotEmpty) {
      await _userService.updateUsername(userId, username);
      await getUser();
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
          decoration: InputDecoration(
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

  void _showAccountsDialog() {
    if (userModel != null && userModel!.accounts.isNotEmpty) {
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
        ),
      );
    } else {
      ErrorUtils.showSnackBar(
          color: Colors.red,
          icon: Icons.error_outline,
          context: context,
          message: 'Accounts not available');
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

  Stream<DocumentSnapshot> _getUserStream() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
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
    // Remove from recent transactions
    recentTransactions
        .removeWhere((transaction) => transaction.id == transactionId);

    // Remove from all transactions
    allTransactions
        .removeWhere((transaction) => transaction.id == transactionId);

    // Recalculate overview data
    _calculateOverviewData(
        allTransactions.isNotEmpty ? allTransactions : recentTransactions);

    // Trigger a state rebuild to update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (canPop) {
        if (!canPop) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: StreamBuilder<DocumentSnapshot>(
        stream: _getUserStream(),
        builder: (context, snapshot) {
          // Automatically refresh data when Firestore document changes
          // if (snapshot.hasData) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     _initializeData();
          //   });
          // }

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: userModel == null
                ? const Center(
                    child: SpinKitThreeBounce(
                      color: AppTheme.primaryDarkColor,
                      size: 20.0,
                    ),
                  )
                : _buildBody(),
            bottomNavigationBar: SleekNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          );
        },
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
    return FutureBuilder<void>(
      future: _initializeTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitThreeBounce(
              color: AppTheme.primaryDarkColor,
              size: 20.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Only pass transactions if they are not empty
          return FinancialInsightsPage(
            allTransactions: allTransactions.isNotEmpty ? allTransactions : [],
            userId: user!.uid,
            userModel: userModel!,
          );
        }
      },
    );
  }
}
