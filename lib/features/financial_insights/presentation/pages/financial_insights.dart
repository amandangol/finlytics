import 'dart:async';
import 'dart:math';
import 'package:expense_tracker/core/common/custom_appbar.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../models/transaction_model.dart';

class FinancialInsightsPage extends StatefulWidget {
  final List<TransactionModel> allTransactions;
  final String userId;

  const FinancialInsightsPage(
      {super.key, required this.allTransactions, required this.userId});

  @override
  _FinancialInsightsPageState createState() => _FinancialInsightsPageState();
}

class _FinancialInsightsPageState extends State<FinancialInsightsPage>
    with SingleTickerProviderStateMixin {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _selectedPeriod = 'Overall';
  DateTimeRange? _customDateRange;
  String _selectedChartType = 'Expense';

  // Animation controller for smooth transitions
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    if (widget.allTransactions.isNotEmpty) {
      _transactions = widget.allTransactions;
      _filteredTransactions = _transactions;
    }

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _filterTransactions(String period) {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 1);

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
      case 'Custom':
        if (_customDateRange != null) {
          startDate = _customDateRange!.start;
          setState(() {
            _filteredTransactions = _transactions.where((transaction) {
              DateTime transactionDate = transaction.date.toDate();
              return transactionDate.isAfter(startDate) &&
                  transactionDate.isBefore(_customDateRange!.end
                      .add(const Duration(hours: 23, minutes: 59)));
            }).toList();
          });
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
      _filteredTransactions = _transactions
          .where((transaction) => transaction.date.toDate().isAfter(startDate))
          .toList();
    });
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFEF6C06),
              primary: const Color(0xFFEF6C06),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _customDateRange) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'Custom';
        _filterTransactions('Custom');
      });
    }
  }

  void _toggleChartType() {
    setState(() {
      _selectedChartType =
          _selectedChartType == 'Expense' ? 'Income' : 'Expense';

      // Trigger re-animation
      _animationController.reset();
      _animationController.forward();
    });
  }

  Color _getCategoryColor(String category) {
    final categoryColors = {
      'Food': const Color(0xFFFFD507),
      'Bills': Colors.purpleAccent,
      'Transport': Colors.pink,
      'Shopping': Colors.green,
      'Entertainment': Colors.cyan,
      'Other': const Color(0xFFEF6C06),
    };
    return categoryColors[category] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 184, 220, 245),
      appBar: const CustomAppBar(title: "Financial Insights"),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: ExpansionTile(
                  enabled: true,
                  title: const Text(
                    'View your financial summary',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryDarkColor,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ),
                  leading: const Icon(
                    Icons.attach_money,
                    color: Colors.green,
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.grey.shade100,
                  collapsedBackgroundColor:
                      Colors.transparent, // Set to transparent
                  collapsedIconColor: Colors.grey.shade600,
                  children: [
                    _buildSummaryMetricsCard(),
                  ],
                ),
              ),
              _buildFilterSection(),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height),
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildChartsContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Period Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...['Overall', 'Today', 'This Week', 'This Month', 'This Year']
                    .map((period) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(period),
                            selected: _selectedPeriod == period,
                            onSelected: (_) => _filterTransactions(period),
                            selectedColor: AppTheme.primaryLightColor,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: _selectedPeriod == period
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: _selectedPeriod == period
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        )),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryLightColor,
                  ),
                  onPressed: () => _selectCustomDateRange(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Chart Type Toggle
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedChartType != 'Expense') _toggleChartType();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedChartType == 'Expense'
                        ? Colors.redAccent
                        : Colors.grey[300],
                    foregroundColor: _selectedChartType == 'Expense'
                        ? Colors.white
                        : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Expense'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedChartType != 'Income') _toggleChartType();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedChartType == 'Income'
                        ? Colors.green
                        : Colors.grey[300],
                    foregroundColor: _selectedChartType == 'Income'
                        ? Colors.white
                        : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Income'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateSummaryMetrics() {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double highestIncome = 0.0;
    double highestExpense = 0.0;
    String highestIncomeCategory = '';
    String highestExpenseCategory = '';

    // Track category-wise totals
    Map<String, double> incomeCategories = {};
    Map<String, double> expenseCategories = {};

    for (var transaction in _filteredTransactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
        incomeCategories.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);

        if (transaction.amount > highestIncome) {
          highestIncome = transaction.amount;
          highestIncomeCategory = transaction.category;
        }
      } else {
        totalExpense += transaction.amount;
        expenseCategories.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);

        if (transaction.amount > highestExpense) {
          highestExpense = transaction.amount;
          highestExpenseCategory = transaction.category;
        }
      }
    }

    // Calculate net balance and savings rate
    double netBalance = totalIncome - totalExpense;
    double savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome * 100).roundToDouble()
        : 0.0;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netBalance': netBalance,
      'savingsRate': savingsRate,
      'highestIncome': highestIncome,
      'highestExpense': highestExpense,
      'highestIncomeCategory': highestIncomeCategory,
      'highestExpenseCategory': highestExpenseCategory,
      'incomeCategories': incomeCategories,
      'expenseCategories': expenseCategories,
    };
  }

  // New method to build summary metrics widget
  Widget _buildSummaryMetricsCard() {
    final metrics = _calculateSummaryMetrics();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryDarkColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Comparative View Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn(
                        'Total Income',
                        NumberFormat.currency(symbol: '\$')
                            .format(metrics['totalIncome']),
                        Colors.green.shade300),
                    _buildMetricColumn(
                        'Total Expense',
                        NumberFormat.currency(symbol: '\$')
                            .format(metrics['totalExpense']),
                        Colors.red.shade300),
                  ],
                ),
                const SizedBox(height: 16),
                // Net Balance and Savings Rate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn(
                        'Net Balance',
                        NumberFormat.currency(symbol: '\$')
                            .format(metrics['netBalance']),
                        metrics['netBalance'] >= 0
                            ? Colors.blue.shade300
                            : Colors.orange.shade300),
                    _buildMetricColumn(
                        'Savings Rate',
                        '${metrics['savingsRate'].toStringAsFixed(1)}%',
                        Colors.purple.shade300),
                  ],
                ),
                const SizedBox(height: 16),
                // Highest Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn(
                        'Highest Income',
                        '${metrics['highestIncomeCategory']}\n\$${NumberFormat.compact().format(metrics['highestIncome'])}',
                        Colors.green.shade200),
                    _buildMetricColumn(
                        'Highest Expense',
                        '${metrics['highestExpenseCategory']}\n\$${NumberFormat.compact().format(metrics['highestExpense'])}',
                        Colors.red.shade200),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build metric columns
  Widget _buildMetricColumn(String title, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color.darken(0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildChartCard(
          'Income vs. Expense',
          _buildIncomeExpenseBarChart(),
        ),
        _buildChartCard(
          'Monthly Transactions',
          _buildMonthlyLineChart(),
        ),
        _buildChartCard(
          'Category Breakdown',
          _buildCategoryBarChart(),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryDarkColor,
              ),
            ),
          ),
          chart,
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart() {
    Map<String, double> categoryTotals = {};

    for (var transaction in _filteredTransactions) {
      if (_selectedChartType == 'Expense' && transaction.type == 'Expense') {
        categoryTotals.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      } else if (_selectedChartType == 'Income' &&
          transaction.type == 'Income') {
        categoryTotals.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    List<BarChartGroupData> barGroups = categoryTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: _getCategoryColor(entry.key),
            width: 20,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: _getCategoryColor(entry.key).withOpacity(0.3),
            ),
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String category = categoryTotals.keys.firstWhere(
                      (key) => key.hashCode == value.toInt(),
                      orElse: () => '',
                    );
                    return Transform.rotate(
                      angle: -pi / 6,
                      child: Text(category,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black87)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 1000,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1000,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            minY: 0,
            maxY: categoryTotals.values.isNotEmpty
                ? categoryTotals.values.reduce(max) * 1.1
                : 1000,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseBarChart() {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var transaction in _filteredTransactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Income');
                      case 1:
                        return const Text('Expense');
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 1000,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: totalIncome,
                    color: Colors.green.shade300,
                    width: 40,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.green.shade100,
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: totalExpense,
                    color: Colors.redAccent.shade200,
                    width: 40,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.red.shade100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyLineChart() {
    Map<int, double> monthlyTotals = {};
    for (var transaction in _transactions) {
      if (_selectedChartType == 'Expense' && transaction.type == 'Expense') {
        int month = transaction.date.toDate().month;
        monthlyTotals.update(month, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      } else if (_selectedChartType == 'Income' &&
          transaction.type == 'Income') {
        int month = transaction.date.toDate().month;
        monthlyTotals.update(month, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    List<FlSpot> spots = List.generate(12, (index) {
      double total = monthlyTotals[index + 1] ?? 0.0;
      return FlSpot(index.toDouble(), total);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const monthNames = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ];
                    return Text(
                      monthNames[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1000,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    );
                  },
                  reservedSize: 50,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1000,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _selectedChartType == 'Expense'
                    ? Colors.redAccent
                    : Colors.green,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: (_selectedChartType == 'Expense'
                          ? Colors.redAccent
                          : Colors.green)
                      .withOpacity(0.3),
                ),
              ),
            ],
            minX: 0,
            maxX: 11,
            minY: 0,
            maxY: monthlyTotals.values.isNotEmpty
                ? monthlyTotals.values.reduce(max) * 1.1
                : 1000,
          ),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
