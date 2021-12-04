import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/utils/image_utils.dart';

import '../../blocs/bloc.dart';
import '../../utils/app_theme.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).colorScheme.secondaryVariant;
    final selectedColor = Palette.tintColor;

    return BlocBuilder<BottomBarBloc, int>(
      bloc: BlocProvider.of<BottomBarBloc>(context),
      builder: (BuildContext context, int state) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          child: BottomNavigationBar(
            currentIndex: state,
            unselectedItemColor: unselectedColor,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            selectedItemColor: selectedColor,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.home,
                  width: 24,
                  height: 24,
                  color: iconColor(context, state, 0),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.friends,
                  width: 24,
                  height: 24,
                  color: iconColor(context, state, 1),
                ),
                label: 'Connections',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.message,
                  width: 24,
                  height: 24,
                  color: iconColor(context, state, 2),
                ),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.notifications,
                  width: 24,
                  height: 24,
                  color: iconColor(context, state, 3),
                ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.settings,
                  width: 24,
                  height: 24,
                  color: iconColor(context, state, 4),
                ),
                label: 'Settings',
              ),
            ],
            onTap: (index) =>
                BlocProvider.of<BottomBarBloc>(context).add(index),
          ),
        );
      },
    );
  }

  Color iconColor(BuildContext context, int activeIndex, int itemIndex) {
    return activeIndex == itemIndex
        ? Palette.tintColor
        : Theme.of(context).colorScheme.secondaryVariant;
  }
}
