import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/provider/currency_provider.dart';

class CurrencySelectionWidget extends StatelessWidget {
  const CurrencySelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text('Select Currency'),
        trailing: DropdownButton<String>(
          value: currencyProvider.currentCurrency,
          underline: const SizedBox(),
          items: CurrencyProvider.supportedCurrencies.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text('${entry.key} - ${entry.value.name}'),
            );
          }).toList(),
          onChanged: (newCurrency) {
            if (newCurrency != null) {
              currencyProvider.changeCurrency(newCurrency);
            }
          },
        ),
      ),
    );
  }
}
