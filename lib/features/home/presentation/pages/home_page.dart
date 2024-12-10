import 'package:expense_tracker/features/home/presentation/widgets/custom_navigation_bar.dart';
import 'package:expense_tracker/screens/turs_ai_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../transaction/presentation/pages/transaction_list/transaction_list_page.dart';
import '../../../transaction/data/transaction_service.dart';
import '../../data/usecases/user_service.dart';
import 'home_content.dart';
import '../widgets/accounts_dialog.dart';
import '../widgets/username_input_dialog.dart';
import '../../../../models.dart';
import '../../../transaction/presentation/pages/add_transaction/add_transaction_page.dart';
import '../../../charts/presentation/pages/charts_page.dart';
// Import the HomeAppBar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  final TransactionService _transactionService = TransactionService();
  int _selectedIndex = 0;

  User? user;
  UserModel? userModel;
  Account? selectedAccount;

  // Variables for overview section
  String _selectedPeriod = 'This Week'; // Default period
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  Map<String, double> expenseByCategory = {};
  bool totalDataFetched = false;
  List<TransactionModel> recentTransactions = [];
  List<TransactionModel> allTransactions = [];

  final TUrSAiPage _tursAiPage = const TUrSAiPage();

  @override
  void initState() {
    super.initState();
    getUser();
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

  Future<void> promptUsernameInput(String userId) async {
    String username = await showDialog(
          context: context,
          builder: (context) => UsernameInputDialog(userId: userId),
        ) ??
        '';

    if (username.isNotEmpty) {
      await _userService.updateUsername(userId, username);
      await getUser(); // Refresh user data after updating username
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Accounts not available')));
    }
  }

  Future<void> _addAccount(String name, double balance) async {
    bool accountExists = userModel!.accounts
        .any((account) => account.name.toLowerCase() == name.toLowerCase());

    if (accountExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Account with the same name already exists!')),
      );
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
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = startDate.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Overall':
        if (totalDataFetched) {
          return;
        }
        startDate = DateTime(1970);
        break;
      default:
        startDate = startDate.subtract(Duration(days: now.weekday - 1));
    }

    List<TransactionModel> transactions =
        await _transactionService.fetchTransactionsByPeriod(
      user!.uid,
      startDate: startDate,
    );

    _calculateOverviewData(transactions);

    if (period == 'Overall') {
      totalDataFetched = true;
      setState(() {
        allTransactions = transactions.toList();
      });
    }

    // Fetch the recent three transactions
    setState(() {
      recentTransactions = transactions.take(3).toList();
    });
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
      child: Scaffold(
        // Replace the existing AppBar with HomeAppBar

        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: userModel == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFEF6C06),
                    strokeWidth: 3,
                  ),
                )
              : _buildBody(),
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
        _selectedIndex == 3 ? _tursAiPage : Container(),
        ProfilePage(
          userModel: userModel!,
        )
      ],
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Expanded(
          child: RedesignedHomeContent(
            userModel: userModel!,
            selectedAccount: selectedAccount,
            selectedPeriod: _selectedPeriod,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            expenseByCategory: expenseByCategory,
            recentTransactions: recentTransactions,
            onShowAccountsDialog: _showAccountsDialog,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _fetchTransactionsForPeriod(period);
            },
            onViewAllTransactions: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TransactionListPage(
                    transactions: allTransactions.isEmpty
                        ? recentTransactions
                        : allTransactions,
                    userId: user!.uid,
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
              child: CircularProgressIndicator(color: Color(0xFFEF6C06)));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ImprovedChartsPage(
            allTransactions: allTransactions,
            userId: user!.uid,
          );
        }
      },
    );
  }
}
