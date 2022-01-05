import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../utils/image_utils.dart';

class NotificationCouterWidget extends StatelessWidget {
  const NotificationCouterWidget({Key? key}) : super(key: key);

  final _style = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ImageIcon(AssetImage(ImageUtils.message)),
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
    );
  }
}
