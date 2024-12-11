import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../core/common/custom_appbar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/provider/currency_provider.dart';
import '../../../../../core/utils/category_helper.dart';
import '../../../../../models/transaction_model.dart';
import '../transaction_details/transaction_details_page.dart';

class TransactionListPage extends StatefulWidget {
  final String userId;
  final List<TransactionModel>? transactions;
  final Function(String)? onTransactionDeleted; // Optional callback

  const TransactionListPage(
      {super.key,
      required this.userId,
      this.transactions,
      this.onTransactionDeleted});

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _selectedPeriod = 'Overall';
  bool _isLoading = true;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _getTransactions();
  }

  Future<void> _getTransactions() async {
    if (widget.transactions != null && widget.transactions!.isNotEmpty) {
      _transactions = widget.transactions!;
      _filterTransactions(_selectedPeriod);
      _isLoading = false;
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _transactions = querySnapshot.docs
            .map((doc) => TransactionModel.fromDocument(doc))
            .toList();
        _filterTransactions(_selectedPeriod);
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      // Handle errors appropriately
    }
  }

  void _filterTransactions(String period) {
    final now = DateTime.now();
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
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Overall':
        startDate = DateTime(1970);
        break;
      case 'Custom':
        if (_customDateRange != null) {
          startDate = _customDateRange!.start;
          _filteredTransactions = _transactions.where((transaction) {
            final transactionDate = transaction.date.toDate();
            return transactionDate.isAfter(startDate) &&
                transactionDate.isBefore(_customDateRange!.end.add(
                  const Duration(hours: 23, minutes: 59),
                ));
          }).toList();
          return;
        } else {
          startDate = DateTime(1970);
        }
        break;
      default:
        startDate = DateTime(1970);
    }

    setState(() {
      _selectedPeriod = period;
      _filteredTransactions = _transactions.where((transaction) {
        final transactionDate = transaction.date.toDate();
        return transactionDate.isAfter(startDate) ||
            transactionDate.isAtSameMomentAs(startDate);
      }).toList();
    });
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _customDateRange) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'Custom';
        _filterTransactions('Custom');
      });
    }
  }

  void _removeTransactionFromList(String transactionId) {
    setState(() {
      // Remove from _transactions list
      _transactions
          .removeWhere((transaction) => transaction.id == transactionId);

      // Reapply filter to update _filteredTransactions
      _filterTransactions(_selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Transactions",
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodDropdown(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryDarkColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          dropdownColor: AppTheme.surfaceColor,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkTextColor,
              ),
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          items: [
            'Today',
            'This Week',
            'This Month',
            'This Year',
            'Overall',
            'Custom'
          ]
              .map((period) => DropdownMenuItem<String>(
                    value: period,
                    child: Text(
                      period,
                      style: AppTheme.textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.darkTextColor),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              if (value == 'Custom') {
                _selectCustomDateRange(context);
              } else {
                _filterTransactions(value);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(
        child: SpinKitThreeBounce(
          color: AppTheme.primaryDarkColor,
          size: 20.0,
        ),
      );
    }

    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          'No Transactions Yet',
          style: AppTheme.textTheme.bodyLarge
              ?.copyWith(color: AppTheme.mutedTextColor),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredTransactions.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppTheme.primaryDarkColor,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return _buildTransactionListItem(transaction);
      },
    );
  }

  Widget _buildTransactionListItem(TransactionModel transaction) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: CategoryHelper.getCategoryColor(transaction.category)
            .withOpacity(0.2),
        child: Icon(
          CategoryHelper.getCategoryIcon(transaction.category),
          color: CategoryHelper.getCategoryColor(transaction.category),
        ),
      ),
      title: Text(
        transaction.category,
        style:
            AppTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy').format(transaction.date.toDate()),
        style: AppTheme.textTheme.bodySmall,
      ),
      trailing: Text(
        currencyProvider.formatCurrency(transaction.amount),
        style: AppTheme.textTheme.bodyLarge?.copyWith(
            color: transaction.type == 'Income'
                ? AppTheme.successColor
                : AppTheme.errorColor,
            fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailsPage(transaction: transaction),
          ),
        );
        if (result == true) {
          _removeTransactionFromList(transaction.id);
        }
      },
    );
  }
}
