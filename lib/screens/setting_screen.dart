import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/provider/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme'),
            subtitle: Text('Choose your app theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  // Update theme mode
                  themeProvider.setThemeMode(newMode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Mode'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Mode'),
                ),
              ],
            ),
          ),
          // You can add more settings here in the future
          Divider(),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Add about app functionality
              showAboutDialog(
                context: context,
                applicationName: 'Your App Name',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
