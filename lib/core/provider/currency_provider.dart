import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  static const String _currencyKey = 'selected_currency';

  // Expanded list of supported currencies
  static final Map<String, CurrencyInfo> supportedCurrencies = {
    // Major Currencies
    'USD': const CurrencyInfo(symbol: '\$', name: 'US Dollar', exchangeRate: 1.0),
    'EUR': const CurrencyInfo(symbol: '€', name: 'Euro', exchangeRate: 0.92),
    'GBP': const CurrencyInfo(symbol: '£', name: 'British Pound', exchangeRate: 0.79),
    'JPY':
        const CurrencyInfo(symbol: '¥', name: 'Japanese Yen', exchangeRate: 149.50),
    'CHF': const CurrencyInfo(symbol: 'CHF', name: 'Swiss Franc', exchangeRate: 0.88),

    // Asian Currencies
    'INR': const CurrencyInfo(symbol: '₹', name: 'Indian Rupee', exchangeRate: 83.20),
    'CNY': const CurrencyInfo(symbol: '¥', name: 'Chinese Yuan', exchangeRate: 7.15),
    'KRW': const CurrencyInfo(
        symbol: '₩', name: 'South Korean Won', exchangeRate: 1330.50),
    'SGD': const CurrencyInfo(
        symbol: 'S\$', name: 'Singapore Dollar', exchangeRate: 1.34),
    'NPR': const CurrencyInfo(
        symbol: '₨', name: 'Nepalese Rupee', exchangeRate: 133.50), // Nepal
    'PHP': const CurrencyInfo(
        symbol: '₱',
        name: 'Philippine Peso',
        exchangeRate: 55.30), // Philippines
    'MMK': const CurrencyInfo(
        symbol: 'K', name: 'Myanmar Kyat', exchangeRate: 2800.00), // Myanmar

    // Middle Eastern Currencies
    'AED': const CurrencyInfo(symbol: 'AED', name: 'UAE Dirham', exchangeRate: 3.67),
    'SAR': const CurrencyInfo(symbol: 'SAR', name: 'Saudi Riyal', exchangeRate: 3.75),
    'OMR': const CurrencyInfo(
        symbol: 'OMR', name: 'Omani Rial', exchangeRate: 0.38), // Oman

    // Other Notable Currencies
    'AUD': const CurrencyInfo(
        symbol: 'A\$', name: 'Australian Dollar', exchangeRate: 1.52),
    'CAD': const CurrencyInfo(
        symbol: 'CA\$', name: 'Canadian Dollar', exchangeRate: 1.35),
    'BRL':
        const CurrencyInfo(symbol: 'R\$', name: 'Brazilian Real', exchangeRate: 4.95),
    'RUB':
        const CurrencyInfo(symbol: '₽', name: 'Russian Ruble', exchangeRate: 90.50),
    'ZAR': const CurrencyInfo(
        symbol: 'R', name: 'South African Rand', exchangeRate: 18.50),

    // African Currencies
    'EGP':
        const CurrencyInfo(symbol: 'E£', name: 'Egyptian Pound', exchangeRate: 30.90),
    'NGN': const CurrencyInfo(
        symbol: '₦', name: 'Nigerian Naira', exchangeRate: 1420.50),

    // Additional Middle Eastern & Gulf Currencies
    'KWD': const CurrencyInfo(
        symbol: 'KWD', name: 'Kuwaiti Dinar', exchangeRate: 0.31), // Kuwait
    'BHD': const CurrencyInfo(
        symbol: 'BHD', name: 'Bahraini Dinar', exchangeRate: 0.38), // Bahrain
    'QAR': const CurrencyInfo(
        symbol: 'QAR', name: 'Qatari Riyal', exchangeRate: 3.64), // Qatar
  };

  String _currentCurrency = 'USD';

  CurrencyProvider() {
    _loadSavedCurrency();
  }

  // Rest of the implementation remains the same as in the previous version
  String get currentCurrency => _currentCurrency;
  CurrencyInfo get currentCurrencyInfo =>
      supportedCurrencies[_currentCurrency]!;

  Future<void> _loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString(_currencyKey);
    if (savedCurrency != null &&
        supportedCurrencies.containsKey(savedCurrency)) {
      _currentCurrency = savedCurrency;
      notifyListeners();
    }
  }

  Future<void> changeCurrency(String newCurrency) async {
    if (supportedCurrencies.containsKey(newCurrency)) {
      _currentCurrency = newCurrency;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, newCurrency);
      notifyListeners();
    }
  }

  String formatCurrency(double amount) {
    final currencyInfo = supportedCurrencies[_currentCurrency]!;
    return '${currencyInfo.symbol}${_formatNumber(amount)}';
  }

  double convertCurrency(double amount, String fromCurrency) {
    final fromRate = supportedCurrencies[fromCurrency]?.exchangeRate ?? 1.0;
    final toRate = supportedCurrencies[_currentCurrency]?.exchangeRate ?? 1.0;
    return (amount / fromRate) * toRate;
  }

  String _formatNumber(double amount) {
    return amount.toStringAsFixed(2);
  }
}

class CurrencyInfo {
  final String symbol;
  final String name;
  final double exchangeRate;

  const CurrencyInfo(
      {required this.symbol, required this.name, required this.exchangeRate});
}
