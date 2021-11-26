import 'package:flutter/material.dart';

import 'custom_expansion_tile.dart';

class SectionWidget extends StatelessWidget {
  const SectionWidget({
    Key? key,
    required this.title,
    this.trailingTitle,
    this.onTrailingPressed,
    required this.child,
    this.initiallyExpanded = false,
    this.maintainState = true,
    this.showDropDownIcon = true,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String? trailingTitle;
  final Function()? onTrailingPressed;
  final Widget child;
  final bool initiallyExpanded;
  final bool showDropDownIcon;
  final Function()? onTap;
  final bool maintainState;

  final _style = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      initiallyExpanded: initiallyExpanded,
      showDropDownIcon: showDropDownIcon,
      maintainState: maintainState,
      tilePadding: const EdgeInsets.all(0.0),
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w400,
          color: Color(0xFF07455B),
        ),
      ),
      trailing: SizedBox(
        height: 43.0,
        child: TextButton(
          onPressed: onTrailingPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0.0),
          ),
          child: Container(
            padding: const EdgeInsets.only(bottom: 0.8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.8),
              ),
            ),
            child: Text(trailingTitle ?? "", style: _style),
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Divider(
            height: 1.5,
            thickness: 1.5,
          ),
        ),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }
}
