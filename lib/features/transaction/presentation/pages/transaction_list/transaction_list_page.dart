import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/category_helper.dart';
import '../../../../../models.dart';
import '../transaction_details/transaction_details_page.dart';

class TransactionListPage extends StatefulWidget {
  final String userId;
  final List<TransactionModel>? transactions;

  const TransactionListPage(
      {super.key, required this.userId, this.transactions});

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _selectedPeriod = 'This Month';
  bool _isLoading = true;
  DateTimeRange? _customDateRange;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    if (widget.transactions != null && widget.transactions!.isNotEmpty) {
      _transactions = widget.transactions!;
      _filterTransactions(_selectedPeriod);
      _isLoading = false;
    } else {
      _fetchAllTransactions();
    }
  }

  Future<void> _fetchAllTransactions() async {
    QuerySnapshot transactionDocs = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _transactions = transactionDocs.docs
          .map((doc) => TransactionModel.fromDocument(doc))
          .toList();
      _filterTransactions(_selectedPeriod);
      _isLoading = false;
    });
  }

  void _filterTransactions(String period) {
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
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Overall':
        startDate = DateTime(1970);
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

  Future<void> _showDownloadDialog() async {
    await Permission.notification.request();
    var notificationStatus = await Permission.notification.status;
    await Permission.manageExternalStorage.request();
    var storageStatus = await Permission.manageExternalStorage.status;
    if (storageStatus.isDenied || notificationStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please give permissions in order to download",
            style: AppTheme.textTheme.bodyMedium,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    String selectedDownloadPeriod = _selectedPeriod;
    String selectedOption = 'All Transactions';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Download Transactions',
            style: AppTheme.textTheme.displaySmall?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 1.5, color: AppTheme.dividerColor),
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDownloadPeriod,
                        dropdownColor: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8.0),
                        icon: Icon(Icons.arrow_drop_down,
                            color: AppTheme.primaryColor),
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
                                        ?.copyWith(
                                            color: AppTheme.darkTextColor),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            if (value == 'Custom') {
                              _selectCustomDateRange(context).then((_) {
                                setState(() {
                                  selectedDownloadPeriod = 'Custom';
                                });
                              });
                            } else {
                              setState(() {
                                selectedDownloadPeriod = value;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: ['All Transactions', 'Income', 'Expense']
                        .map((String key) {
                      return RadioListTile<String>(
                        title: Text(
                          key,
                          style: AppTheme.textTheme.bodyLarge,
                        ),
                        value: key,
                        activeColor: AppTheme.primaryColor,
                        groupValue: selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            selectedOption = value ?? 'All Transactions';
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _downloadTransactions(
                    selectedDownloadPeriod, selectedOption, 'CSV');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Downloading CSV...",
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: Text(
                'Download as CSV',
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _downloadTransactions(
                    selectedDownloadPeriod, selectedOption, 'PDF');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Downloading PDF...",
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: Text(
                'Download as PDF',
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadTransactions(
      String period, String option, String format) async {
    List<TransactionModel> transactionsToDownload;

    // Filter transactions based on period
    if (period != 'Overall') {
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
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          break;
        case 'Custom':
          if (_customDateRange != null) {
            startDate = _customDateRange!.start;
            transactionsToDownload = _transactions.where((transaction) {
              DateTime transactionDate = transaction.date.toDate();
              return transactionDate.isAfter(startDate) &&
                  transactionDate.isBefore(_customDateRange!.end
                      .add(const Duration(hours: 23, minutes: 59)));
            }).toList();
            break;
          } else {
            startDate = DateTime(1970);
          }
          break;
        default:
          startDate = DateTime(1970);
      }

      transactionsToDownload = _transactions.where((transaction) {
        final transactionDate = transaction.date.toDate();
        return transactionDate.isAfter(startDate) ||
            transactionDate.isAtSameMomentAs(startDate);
      }).toList();
    } else {
      transactionsToDownload = List.from(_transactions);
    }

    // Further filter transactions based on option (All, Income, Expense)
    if (option != 'All Transactions') {
      transactionsToDownload = transactionsToDownload
          .where((transaction) => transaction.type == option)
          .toList();
    }

    if (transactionsToDownload.isEmpty) {
      const SnackBar(content: Text("No transactions for selected period"));
    } else {
      // Download in selected format
      if (format == 'CSV') {
        await _downloadCSV(transactionsToDownload);
      } else if (format == 'PDF') {
        await _downloadPDF(transactionsToDownload);
      }
    }
  }

  Future<void> _downloadCSV(List<TransactionModel> transactions) async {
    List<List<dynamic>> csvData = [
      ['Category', 'Date', 'Amount(in Rs.)', 'Type']
    ];

    for (var transaction in transactions) {
      csvData.add([
        transaction.category,
        "${transaction.date.toDate().toLocal().day.toString().padLeft(2, '0')}/${transaction.date.toDate().toLocal().month.toString().padLeft(2, '0')}/${transaction.date.toDate().toLocal().year}",
        (transaction.amount.toString()),
        transaction.type,
      ]);
    }

    String csvString = const ListToCsvConverter().convert(csvData);
    final path =
        "/storage/emulated/0/Download/transactions_TrackUrSpends_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csvString);

    _showNotification(
        "CSV Downloaded", "Your CSV file has been downloaded to $path", path);
  }

  Future<void> _downloadPDF(List<TransactionModel> transactions) async {
    final pdf = pw.Document();

    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'),
    );

    final img = await rootBundle.load('assets/images/logo.png');
    final imageBytes = img.buffer.asUint8List();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20.0),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(
                  pw.MemoryImage(imageBytes),
                  height: 50.0,
                ),
                pw.Text(
                  'TrackUrSpends Transaction Statement',
                  style: pw.TextStyle(
                    fontSize: 24.0,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20.0),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Transactions',
                  style: pw.TextStyle(
                    fontSize: 16.0,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
                pw.Text(
                  'Downloaded on ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10.0,
                    color: PdfColors.grey,
                    font: font,
                  ),
                ),
              ],
            ),
            pw.Divider(),
            pw.ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final formattedDate =
                    "${transaction.date.toDate().day.toString().padLeft(2, '0')}/${transaction.date.toDate().month.toString().padLeft(2, '0')}/${transaction.date.toDate().year} ${transaction.date.toDate().hour.toString().padLeft(2, '0')}:${transaction.date.toDate().minute.toString().padLeft(2, '0')}";
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10.0),
                  padding: const pw.EdgeInsets.all(10.0),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(10.0),
                    color: transaction.type == 'Expense'
                        ? PdfColors.red100
                        : PdfColors.green100,
                    border: pw.Border.all(
                      color: transaction.type == 'Expense'
                          ? PdfColors.red900
                          : PdfColors.green900,
                      width: 1.0,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            transaction.category,
                            style: pw.TextStyle(
                              fontSize: 16.0,
                              fontWeight: pw.FontWeight.bold,
                              font: font,
                            ),
                          ),
                          pw.Text(
                            'Rs. ${transaction.amount.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 16.0,
                              fontWeight: pw.FontWeight.bold,
                              color: transaction.type == 'Expense'
                                  ? PdfColors.red
                                  : PdfColors.green,
                              font: font,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8.0),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Date: ',
                            style: pw.TextStyle(
                              fontSize: 14.0,
                              fontWeight: pw.FontWeight.bold,
                              font: font,
                            ),
                          ),
                          pw.Text(
                            formattedDate,
                            style: pw.TextStyle(
                              fontSize: 14.0,
                              font: font,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4.0),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Account: ',
                            style: pw.TextStyle(
                              fontSize: 14.0,
                              fontWeight: pw.FontWeight.bold,
                              font: font,
                            ),
                          ),
                          pw.Text(
                            transaction.account,
                            style: pw.TextStyle(
                              fontSize: 14.0,
                              font: font,
                            ),
                          ),
                        ],
                      ),
                      if (transaction.details != null &&
                          transaction.details!.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 4.0),
                            pw.Text(
                              'Details: ',
                              style: pw.TextStyle(
                                fontSize: 14.0,
                                fontWeight: pw.FontWeight.bold,
                                font: font,
                              ),
                            ),
                            pw.Text(
                              transaction.details!,
                              style: pw.TextStyle(
                                fontSize: 14.0,
                                font: font,
                              ),
                            ),
                          ],
                        ),
                      pw.SizedBox(height: 4.0),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Photos Attached: ',
                            style: pw.TextStyle(
                              fontSize: 14.0,
                              fontWeight: pw.FontWeight.bold,
                              font: font,
                            ),
                          ),
                          pw.Text(
                            transaction.havePhotos ? 'Yes' : 'No',
                            style: pw.TextStyle(
                              fontSize: 14.0,
                              font: font,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ];
        },
      ),
    );

    final path =
        "/storage/emulated/0/Download/transactions_TrackUrSpends_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    _showNotification(
        "PDF Downloaded", "Your PDF file has been downloaded to $path", path);
  }

  Future<void> _showNotification(
      String title, String body, String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: filePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: AppTheme.textTheme.displayMedium?.copyWith(
              color: AppTheme.lightTheme.appBarTheme.titleTextStyle?.color),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: AppTheme.darkTextColor),
            onPressed: _showDownloadDialog,
          ),
        ],
      ),
      body: Padding(
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
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          dropdownColor: AppTheme.surfaceColor,
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
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
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
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
      separatorBuilder: (context, index) => Divider(
        color: AppTheme.dividerColor.withOpacity(0.3),
        height: 1,
      ),
      itemBuilder: (context, index) {
        TransactionModel transaction = _filteredTransactions[index];
        return _buildTransactionListItem(transaction);
      },
    );
  }

  Widget _buildTransactionListItem(TransactionModel transaction) {
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
        '₹${transaction.amount.toStringAsFixed(2)}',
        style: AppTheme.textTheme.bodyLarge?.copyWith(
            color: transaction.type == 'Income'
                ? AppTheme.successColor
                : AppTheme.errorColor,
            fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        bool? result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailsPage(transaction: transaction),
          ),
        );
        if (result == true) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }
}
