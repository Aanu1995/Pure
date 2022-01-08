import 'package:flutter/material.dart';
import '../../../../../model/pure_user_model.dart';
import 'package:pure/views/widgets/avatar.dart';

class TaggedUsers extends StatelessWidget {
  final List<PureUser> members;
  final Function(String) onUserPressed;
  const TaggedUsers(
      {Key? key, required this.members, required this.onUserPressed})
      : super(key: key);

  final _style = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0.4,
      initialChildSize: 0.4,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView.separated(
            itemCount: members.length,
            controller: scrollController,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: Avartar2(imageURL: member.photoURL),
                title: RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: member.fullName,
                        style: _style.copyWith(
                          color: Theme.of(context).colorScheme.primaryVariant,
                        ),
                      ),
                      TextSpan(
                        text: "  @${member.username}",
                        style: _style.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondaryVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => onUserPressed.call("${member.username} "),
              );
            },
          ),
        );
      },
    );
  }
}
