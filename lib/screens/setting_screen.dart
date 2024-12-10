import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers (you'll need to implement these)
import '../core/provider/currency_provider.dart';
import '../core/provider/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Theme Selection Bottom Sheet
  void _showThemeBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('System Default'),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Light Mode'),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // About Bottom Sheet
  void _showAboutBottomSheet(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Finlytics',
      applicationVersion: '1.0.0',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Setting
          Card(
            margin: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _showThemeBottomSheet(context),
              child: ListTile(
                title: const Text('Theme'),
                subtitle: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    String themeName;
                    switch (themeProvider.themeMode) {
                      case ThemeMode.system:
                        themeName = 'System Default';
                        break;
                      case ThemeMode.light:
                        themeName = 'Light Mode';
                        break;
                      case ThemeMode.dark:
                        themeName = 'Dark Mode';
                        break;
                    }
                    return Text(themeName);
                  },
                ),
                trailing: const Icon(Icons.palette_outlined),
              ),
            ),
          ),
          const Divider(),

          // Currency Setting
          Card(
            margin: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                _showCurrencyBottomSheet(context);
              },
              child: ListTile(
                title: const Text('Currency'),
                subtitle: Consumer<CurrencyProvider>(
                  builder: (context, currencyProvider, child) {
                    final currentCurrency =
                        currencyProvider.currentCurrencyInfo;
                    return Text(
                      '${currentCurrency.name} (${currentCurrency.symbol})',
                    );
                  },
                ),
                trailing: const Icon(Icons.currency_exchange),
              ),
            ),
          ),
          const Divider(),

          const Divider(),

          Card(
            margin: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _showAboutBottomSheet(context),
              child: const ListTile(
                title: Text('About'),
                trailing: Icon(Icons.info_outline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Currency Bottom Sheet (similar to your existing implementation)
  void _showCurrencyBottomSheet(BuildContext context) {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: CurrencyProvider.supportedCurrencies.length,
          itemBuilder: (context, index) {
            final currencyEntry =
                CurrencyProvider.supportedCurrencies.entries.elementAt(index);
            return ListTile(
              title: Text('${currencyEntry.key} - ${currencyEntry.value.name}'),
              subtitle: Text('Symbol: ${currencyEntry.value.symbol}'),
              onTap: () {
                currencyProvider.changeCurrency(currencyEntry.key);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
