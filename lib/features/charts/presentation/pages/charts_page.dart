import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../models.dart';

class ImprovedChartsPage extends StatefulWidget {
  final List<TransactionModel> allTransactions;
  final String userId;

  const ImprovedChartsPage(
      {super.key, required this.allTransactions, required this.userId});

  @override
  _ImprovedChartsPageState createState() => _ImprovedChartsPageState();
}

class _ImprovedChartsPageState extends State<ImprovedChartsPage>
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
    _transactions = widget.allTransactions;
    _filteredTransactions = _transactions;

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Financial Insights',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFEF6C06),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildChartsPageBody(),
    );
  }

  Widget _buildChartsPageBody() {
    return Column(
      children: [
        _buildPeriodSelector(),
        _buildChartTypeToggle(),
        Expanded(
          child: FadeTransition(
            opacity: _animationController,
            child: _buildCharts(),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...['Overall', 'Today', 'This Week', 'This Month', 'This Year']
                .map((period) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(period),
                        selected: _selectedPeriod == period,
                        onSelected: (_) => _filterTransactions(period),
                        selectedColor: const Color(0xFFEF6C06),
                        labelStyle: TextStyle(
                          color: _selectedPeriod == period
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ))
                .toList(),
            IconButton(
              icon: Icon(
                Icons.date_range,
                color: const Color(0xFFEF6C06),
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black12,
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
              onPressed: () => _selectCustomDateRange(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text('Expense'),
              selected: _selectedChartType == 'Expense',
              onSelected: (_) {
                if (_selectedChartType != 'Expense') _toggleChartType();
              },
              selectedColor: Colors.redAccent,
              labelStyle: TextStyle(
                color: _selectedChartType == 'Expense'
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: ChoiceChip(
              label: const Text('Income'),
              selected: _selectedChartType == 'Income',
              onSelected: (_) {
                if (_selectedChartType != 'Income') _toggleChartType();
              },
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: _selectedChartType == 'Income'
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildChartContainer(
          'Income vs. Expense',
          _buildIncomeExpenseBarChart(),
        ),
        _buildChartContainer(
          'Monthly Transactions',
          _buildMonthlyLineChart(),
        ),
        _buildChartContainer(
          'Category Breakdown',
          _buildCategoryBarChart(),
        ),
      ],
    );
  }

  Widget _buildChartContainer(String title, Widget chart) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFEF6C06),
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black12,
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
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
