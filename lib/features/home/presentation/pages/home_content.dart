import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/currency_provider.dart';
import '../../../../core/provider/theme_provider.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../models/account_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../../models/user_model.dart';
import '../../../transaction/presentation/pages/transaction_details/transaction_details_page.dart';
import '../widgets/welcome_card.dart';

class HomeContent extends StatefulWidget {
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
  final bool? isLoading;

  const HomeContent({
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
    this.isLoading,
  });

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode0 = themeProvider.themeMode == ThemeMode.dark;

    final cardColor = isDarkMode0
        ? AppTheme.darkTheme.cardColor
        : AppTheme.lightTheme.cardColor;

    final textColor =
        isDarkMode0 ? AppTheme.lightTextColor : AppTheme.darkTextColor;

    return Scaffold(
      // backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 230, 236, 241), // Soft light blue
              Color.fromARGB(255, 220, 239, 225), // Soft light green
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              floating: true,
              elevation: 0,
              pinned: true,
              backgroundColor: AppTheme.surfaceColor,
              flexibleSpace: FlexibleSpaceBar(
                // collapseMode: CollapseMode.parallax,
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: const Text(
                  "Finlytics",
                  style: TextStyle(
                    color: AppTheme.secondaryDarkColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/banner.png'),
                      alignment: Alignment.centerRight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  WelcomeCard(
                    userModel: widget.userModel,
                    totalIncome: widget.totalIncome,
                    totalExpense: widget.totalExpense,
                  ),
                  const SizedBox(height: 20),
                  _buildBalanceCard(cardColor, textColor),
                  const SizedBox(height: 20),
                  _buildOverviewSection(cardColor, textColor),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Color cardColor, Color textColor) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return GestureDetector(
      onTap: widget.onShowAccountsDialog,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade600, // Top color
              Colors.blue.shade900, // Bottom color
            ],
          ),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  LucideIcons.wallet,
                  color: Colors.white70,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              currencyProvider.formatCurrency(widget.selectedAccount != null
                  ? widget.selectedAccount!.balance
                  : widget.userModel.totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            // New row to show initial balance
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Text(
                    'Initial Balance: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    currencyProvider.formatCurrency(
                        widget.selectedAccount != null
                            ? widget.selectedAccount!.initialBalance
                            : widget.userModel.totalInitialBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(
                  LucideIcons.info,
                  color: Colors.white70,
                  size: 16,
                ),
                SizedBox(width: 8),
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
    if (widget.isLoading == true) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
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
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: SpinKitThreeBounce(
              color: AppTheme.primaryDarkColor,
              size: 30.0,
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms);
    }
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
          Column(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIncomeExpenseBox(
                        'Expense', widget.totalExpense, false),
                    const SizedBox(width: 10),
                    _buildIncomeExpenseBox('Income', widget.totalIncome, true),
                  ],
                ),
              ),
              _buildPieChart(),
              _buildTransactionList(textColor),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms);
  }

  Widget _buildPeriodDropdown(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: widget.selectedPeriod,
        dropdownColor: AppTheme.cardColor,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkTextColor,
            ),
        borderRadius: BorderRadius.circular(12),
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
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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
              currencyProvider.formatCurrency(amount),
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
                    style: AppTheme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.primaryDarkColor),
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
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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
                child: const Text(
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
                style: AppTheme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.primaryDarkColor),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
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
                  transaction.category,
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
                  currencyProvider.formatCurrency(transaction.amount),
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
