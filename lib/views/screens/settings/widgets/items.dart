import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/palette.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String icon;
  final String? trailingText;
  final bool hideTrailingIcon;
  final Color? color;
  final Function()? onTap;

  const SettingItem({
    Key? key,
    required this.title,
    required this.icon,
    this.trailingText,
    this.color,
    this.hideTrailingIcon = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20.0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Image.asset(icon, width: 20, height: 20, color: color),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
      trailing: hideTrailingIcon ? null : Icon(CupertinoIcons.chevron_right),
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final String icon;
  final String? trailingText;
  final bool hideTrailingIcon;
  final Color? color;
  final Function()? onTap;

  const Item({
    Key? key,
    required this.title,
    required this.icon,
    this.trailingText,
    this.color,
    this.hideTrailingIcon = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      horizontalTitleGap: 0,
      leading: Image.asset(
        icon,
        width: 24,
        height: 24,
        color: color ?? Theme.of(context).colorScheme.primaryVariant,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
            ),
        ],
      ),
      trailing: hideTrailingIcon ? null : Icon(CupertinoIcons.chevron_right),
    );
  }
}

class TitleHeader extends StatelessWidget {
  final String title;
  final Widget? child;
  final double? fontSize;
  const TitleHeader({Key? key, required this.title, this.child, this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize ?? 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: Palette.migraFontFamily,
              ),
            ),
          ),
          child ?? Offstage(),
        ],
      ),
    );
  }
}
