import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_theme.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/shimmers/loading_shimmer.dart';

class ConnectionProfile extends StatelessWidget {
  final bool showSeparator;
  const ConnectionProfile({Key? key, this.showSeparator = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileSuccess) {
          final user = state.user;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                dense: true,
                horizontalTitleGap: 0.0,
                leading: Avartar(size: 40.0, imageURL: user.photoURL),
                title: Text(
                  user.fullName,
                  key: ValueKey(user.id),
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
                subtitle: Text(
                  user.about!.isEmpty ? "--" : user.about!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 1.3,
                  child: BlocBuilder<GroupCubit, GroupState>(
                    builder: (context, groupState) {
                      if (groupState is GroupMembers) {
                        final isMember =
                            isUserAMember(groupState.members, user);

                        return Checkbox(
                          value: isMember,
                          activeColor: Palette.tintColor,
                          shape: CircleBorder(),
                          onChanged: (active) => active!
                              ? context.read<GroupCubit>().addMember(user)
                              : context.read<GroupCubit>().removeMember(user),
                        );
                      }
                      return Offstage();
                    },
                  ),
                ),
              ),
              if (showSeparator) const Divider(height: 0.0),
            ],
          );
        }
        return const SingleShimmer();
      },
    );
  }

  bool isUserAMember(List<PureUser> members, PureUser user) {
    return members.firstWhereOrNull((element) => element.id == user.id) != null;
  }
}

class MemberProfile extends StatelessWidget {
  const MemberProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, memberState) {
        if (memberState is GroupMembers && memberState.members.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SizedBox(
              width: 1.0.sw,
              height: 100.0,
              child: ListView.builder(
                itemCount: memberState.members.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final user = memberState.members[index];
                  return SizedBox(
                    width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Avartar2(size: 30.0, imageURL: user.photoURL),
                              const SizedBox(height: 8.0),
                              Text(
                                user.fullName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -10.0,
                          right: -4.0,
                          child: IconButton(
                            onPressed: () =>
                                context.read<GroupCubit>().removeMember(user),
                            icon: CircleAvatar(
                              radius: 10,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                              child: Icon(
                                Icons.close,
                                size: 14.0,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
        return Offstage();
      },
    );
  }
}

class AllMembers extends StatelessWidget {
  const AllMembers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        if (state is GroupMembers) {
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 75,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: state.members.length,
            itemBuilder: (context, index) {
              final user = state.members[index];
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Avartar2(imageURL: user.photoURL),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      user.fullName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -14.0,
                    right: -10.0,
                    child: IconButton(
                      onPressed: () =>
                          context.read<GroupCubit>().removeMember(user),
                      icon: CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryVariant,
                        child: Icon(
                          Icons.close,
                          size: 14.0,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        }
        return Offstage();
      },
    );
  }
}
