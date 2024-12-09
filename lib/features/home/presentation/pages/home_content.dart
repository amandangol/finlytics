import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/theme_provider.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../models.dart';
import '../../../transaction/presentation/pages/transaction_details/transaction_details_page.dart';

class RedesignedHomeContent extends StatefulWidget {
  final UserModel userModel;
  final Account? selectedAccount;
  final String selectedPeriod;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> expenseByCategory;
  final List<TransactionModel> recentTransactions;
  final VoidCallback onShowAccountsDialog;
  final Function(String) onPeriodChanged;
  final VoidCallback onViewAllTransactions;

  const RedesignedHomeContent({
    super.key,
    required this.userModel,
    this.selectedAccount,
    required this.selectedPeriod,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
    required this.recentTransactions,
    required this.onShowAccountsDialog,
    required this.onPeriodChanged,
    required this.onViewAllTransactions,
  });

  @override
  _RedesignedHomeContentState createState() => _RedesignedHomeContentState();
}

class _RedesignedHomeContentState extends State<RedesignedHomeContent>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final name = widget.userModel.username.split(' ').first;

    if (hour < 12) {
      return 'Rise & Shine, $name';
    } else if (hour < 17) {
      return 'Afternoon Boost, $name';
    } else {
      return 'Evening Vibes, $name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final _isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final backgroundColor = _isDarkMode
        ? AppTheme.darkTheme.scaffoldBackgroundColor
        : AppTheme.lightTheme.scaffoldBackgroundColor;

    final cardColor = _isDarkMode
        ? AppTheme.darkTheme.cardColor
        : AppTheme.lightTheme.cardColor;

    final textColor =
        _isDarkMode ? AppTheme.lightTextColor : AppTheme.darkTextColor;

    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildBalanceCard(cardColor, textColor),
                    const SizedBox(height: 20),
                    _buildOverviewSection(cardColor, textColor),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: widget.onShowAccountsDialog,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedAccount != null
                      ? widget.selectedAccount!.name
                      : 'Total Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  LucideIcons.wallet,
                  color: Colors.white70,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '₹${widget.selectedAccount != null ? widget.selectedAccount!.balance.toString() : widget.userModel.totalBalance}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to view account details',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms),
    );
  }

  Widget _buildOverviewSection(Color cardColor, Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: AppTheme.textTheme.displayMedium?.copyWith(
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                _buildPeriodDropdown(textColor),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIncomeExpenseBox('Expense', widget.totalExpense, false),
                const SizedBox(width: 10),
                _buildIncomeExpenseBox('Income', widget.totalIncome, true),
              ],
            ),
          ),
          _buildPieChart(),
          _buildTransactionList(textColor),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms);
  }

  Widget _buildPeriodDropdown(Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: widget.selectedPeriod,
        dropdownColor: isDarkMode ? AppTheme.darkTheme.cardColor : Colors.white,
        underline: const SizedBox(),
        icon: Icon(LucideIcons.chevronDown, color: textColor),
        items: ['Today', 'This Week', 'This Month', 'Overall']
            .map((period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(
                    period,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            widget.onPeriodChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildIncomeExpenseBox(String title, double amount, bool isIncome) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isIncome
              ? AppTheme.successColor.withOpacity(0.1)
              : AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isIncome
                ? AppTheme.successColor.withOpacity(0.2)
                : AppTheme.errorColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isIncome ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                Icon(
                  isIncome ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                  color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: AppTheme.textTheme.displayMedium?.copyWith(
              fontSize: 18,
              color:
                  isDarkMode ? AppTheme.lightTextColor : AppTheme.darkTextColor,
            ),
          ),
          const SizedBox(height: 16),
          widget.expenseByCategory.isEmpty
              ? Center(
                  child: Text(
                    'No expense data available',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color:
                          isDarkMode ? Colors.white54 : AppTheme.lightTextColor,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(),
                            centerSpaceRadius: 50,
                            sectionsSpace: 3,
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  setState(() {
                                    _touchedIndex = -1;
                                  });
                                  return;
                                }
                                setState(() {
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.expenseByCategory.keys.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(category),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style:
                                      AppTheme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? AppTheme.lightTextColor
                                        : AppTheme.darkTextColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (widget.expenseByCategory.isEmpty) {
      return [PieChartSectionData(color: Colors.grey)];
    }

    final totalAmount = widget.expenseByCategory.values
        .fold(0.0, (sum, amount) => sum + amount);

    final categoryList = widget.expenseByCategory.keys.toList();

    return categoryList.map((category) {
      final amount = widget.expenseByCategory[category]!;
      final percentage = (amount / totalAmount) * 100;
      final isTouched = _touchedIndex == categoryList.indexOf(category);
      final double radius = isTouched ? 70 : 60;

      return PieChartSectionData(
        color: _getCategoryColor(category),
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: percentage > 5, // Only show title for sections > 5%
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    return CategoryHelper.getCategoryColor(category);
  }

  Widget _buildTransactionList(Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTheme.textTheme.displayMedium?.copyWith(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllTransactions,
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Center(
              child: Text(
                'No recent transactions',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white54 : AppTheme.lightTextColor,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.recentTransactions.length > 5
                ? 5
                : widget.recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = widget.recentTransactions[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailsPage(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(transaction.category)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CategoryHelper.getCategoryIcon(transaction.category),
                    color: _getCategoryColor(transaction.category),
                    size: 24,
                  ),
                ),
                title: Text(
                  transaction.category!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppTheme.lightTextColor
                        : AppTheme.darkTextColor,
                  ),
                ),
                subtitle: Text(
                  transaction.details.toString(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  '₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.type == "Expense"
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}