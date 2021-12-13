import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/chat_service.dart';
import '../../../../services/search_service.dart';
import '../../../../utils/app_theme.dart';
import '../../../../utils/navigate.dart';
import 'add_participants_screen.dart';
import 'edit_group_description_screen.dart';
import 'edit_group_subject_screen.dart';
import 'widget/group_banner.dart';
import 'widget/participants.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;
  final List<PureUser> participants;
  final ValueChanged<ChatModel> onChatChanged;
  const GroupInfoScreen({
    Key? key,
    required this.chat,
    required this.participants,
    required this.onChatChanged,
  }) : super(key: key);
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late ChatModel chat;

  final _style = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
  }

  // update as state in Bloc Listener updates
  void participantStateListener(BuildContext context, ParticipantState state) {
    if (state is RemovingParticipant) {
      setState(() => widget.participants.remove(state.participant));
    } else if (state is AddingAdmin) {
      final newChat = chat.copyWithForAdmin(state.memberId, true);
      widget.onChatChanged.call(newChat);
      setState(() => chat = newChat);
    } else if (state is RemovingAdmin) {
      final newChat = chat.copyWithForAdmin(state.memberId, false);
      widget.onChatChanged.call(newChat);
      setState(() => chat = newChat);
    } else if (state is FailedToRemoveParticipant) {
      widget.participants.insert(state.index, state.participant);
    }
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
      body: BlocListener<ParticipantCubit, ParticipantState>(
        listener: participantStateListener,
        child: BlocListener<GroupChatCubit, GroupChatState>(
          listenWhen: (pre, current) => current is GroupChatUpdated,
          listener: (context, state) {
            if (state is GroupChatUpdated) {
              widget.onChatChanged.call(state.chatModel);
              setState(() => chat = state.chatModel);
            }
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 1.sw * 0.5,
                  backgroundColor: Colors.black45,
                  flexibleSpace: GroupBanner(chat: chat),
                )
              ];
            },
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Add group Name and Description
                    Column(
                      children: [
                        ListTile(
                          dense: true,
                          title: Text(
                            chat.groupName!,
                            style: _style.copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => editGroupSubject(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Divider(height: 0.0),
                        ),
                        ListTile(
                          dense: true,
                          title: Text(
                            chat.groupDescription!.isEmpty
                                ? "Add group description"
                                : chat.groupDescription!,
                            style: _style.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => editGroupDescription(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // Participants
                    Participants(
                      chat: widget.chat,
                      participants: widget.participants,
                      onAddNewParticipantstapped: () => addParticipant(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> editGroupSubject() async {
    push(
      context: context,
      page: BlocProvider.value(
        value: context.read<GroupChatCubit>(),
        child: EditGroupSubject(chat: chat),
      ),
    );
  }

  Future<void> editGroupDescription() async {
    push(
      context: context,
      page: BlocProvider.value(
        value: context.read<GroupChatCubit>(),
        child: EditGroupDescription(chat: chat),
      ),
    );
  }

  void addParticipant(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AddParticipantCubit(ChatServiceImp())),
            BlocProvider(create: (_) => SearchFriendBloc(SearchServiceImpl())),
            BlocProvider(create: (_) => ParticipantCubit(ChatServiceImp())),
          ],
          child: AddNewParticipant(
            chat: chat,
            groupMembers:
                widget.participants.toList().map((e) => e.id).toList(),
            onNewParticipantsAdded: (newMembers) {
              setState(() {
                widget.participants.addAll(newMembers);
                widget.participants
                    .sort((a, b) => a.fullName.compareTo(b.fullName));
              });
            },
          ),
        );
      }),
    );
  }
}
