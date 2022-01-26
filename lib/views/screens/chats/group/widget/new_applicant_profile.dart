import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../widgets/avatar.dart';

class NewApplicantProfile extends StatelessWidget {
  const NewApplicantProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddParticipantCubit, GroupState>(
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
                            onPressed: () => context
                                .read<AddParticipantCubit>()
                                .removeMember(user),
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
