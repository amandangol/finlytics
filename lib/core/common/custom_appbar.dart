import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).appBarTheme.toolbarTextStyle),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: Theme.of(context).appBarTheme.elevation,
      iconTheme: Theme.of(context).appBarTheme.iconTheme,
    );
  }
}
