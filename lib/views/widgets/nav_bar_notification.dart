import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/bloc.dart';
import '../../utils/image_utils.dart';

class NotificationCouterWidget extends StatelessWidget {
  const NotificationCouterWidget({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: ImageIcon(AssetImage(ImageUtils.message)),
        ),
        Positioned(
          top: -2.0,
          right: 10.0,
          child: BlocBuilder<UnReadChatCubit, int>(
            builder: (context, state) {
              if (state > 0)
                return Badge(
                  badgeColor: Colors.red,
                  elevation: 0.0,
                  animationDuration: Duration.zero,
                  padding: EdgeInsets.all(6.0),
                  badgeContent: Text(
                    state.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.05,
                      color: Colors.white,
                    ),
                  ),
                );
              return Offstage();
            },
          ),
        )
      ],
    );
  }
}
