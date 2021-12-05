import 'package:flutter/material.dart';

import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_theme.dart';
import 'widget/participants.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;
  final List<PureUser> participants;
  const GroupInfoScreen(
      {Key? key, required this.chat, required this.participants})
      : super(key: key);
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late ChatModel chat;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
          chat.groupName!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17.5,
            fontFamily: Palette.sanFontFamily,
            color: Palette.tintColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Participants(participants: widget.participants),
          ],
        ),
      ),
    );
  }
}
