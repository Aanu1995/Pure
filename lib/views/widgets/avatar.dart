import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../utils/image_utils.dart';

class Avartar extends StatelessWidget {
  final String imageURL;
  final String? localURL;
  final double size;
  final double? ringSize;
  final bool hidePresence;
  const Avartar({
    Key? key,
    required this.imageURL,
    required this.size,
    this.localURL,
    this.ringSize,
    this.hidePresence = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          backgroundImage: AssetImage(localURL ?? ImageUtils.user),
          foregroundImage:
              imageURL.isEmpty ? null : CachedNetworkImageProvider(imageURL),
        ),
        if (hidePresence == false)
          BlocBuilder<UserPresenceCubit, UserPresenceState>(
            builder: (context, state) {
              return Positioned(
                bottom: size * 0.05,
                right: size * 0.3,
                child: AnimatedOpacity(
                  opacity:
                      state is UserPresenceSuccess && state.presence.isOnline
                          ? 1.0
                          : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: CircleAvatar(
                    radius: size * 0.15,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: size * 0.12,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              );
            },
          )
      ],
    );
  }
}

class Avartar2 extends StatelessWidget {
  final String imageURL;
  final String? localURL;
  final double? size;

  final bool hidePresence;
  const Avartar2({
    Key? key,
    required this.imageURL,
    this.size,
    this.localURL,
    this.hidePresence = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      backgroundImage: AssetImage(localURL ?? ImageUtils.user),
      foregroundImage:
          imageURL.isEmpty ? null : CachedNetworkImageProvider(imageURL),
    );
  }
}
