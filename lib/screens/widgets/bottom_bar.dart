import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../blocs/chats/chats/unread_chat.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_utils.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  final _style = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).colorScheme.secondaryVariant;
    final selectedColor = Palette.tintColor;
    final iconSize = 24.0;

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
                  width: iconSize,
                  height: iconSize,
                  color: iconColor(context, state, 0),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.friends,
                  width: iconSize,
                  height: iconSize,
                  color: iconColor(context, state, 1),
                ),
                label: 'Connections',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image.asset(
                        ImageUtils.message,
                        width: iconSize,
                        height: iconSize,
                        color: iconColor(context, state, 2),
                      ),
                    ),
                    Positioned(
                      top: -2.0,
                      right: 10.0,
                      child: BlocBuilder<UnReadChatCubit, int>(
                        builder: (context, state) {
                          if (state > 0) {
                            return Badge(
                              badgeColor: Colors.red,
                              elevation: 0.0,
                              padding: EdgeInsets.all(6.0),
                              animationType: BadgeAnimationType.fade,
                              badgeContent: Text(
                                state.toString(),
                                style: _style.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }
                          return Offstage();
                        },
                      ),
                    )
                  ],
                ),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.notifications,
                  width: iconSize,
                  height: iconSize,
                  color: iconColor(context, state, 3),
                ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  ImageUtils.settings,
                  width: iconSize,
                  height: iconSize,
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
